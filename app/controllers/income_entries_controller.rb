class IncomeEntriesController < ApplicationController
  before_action :api_user
  before_action :set_site
  before_action :validate_site
  before_action :set_income_entry, only: [:show, :update, :destroy]

  # GET /income_entries.json
  def index
    @income_entries = @site.income_entries.includes(:unit, :user).order(created_at: :desc)
    
    # Filter by income_month/income_year (period-based) or fallback to date range
    if params[:income_year].present? && params[:income_month].present?
      @income_entries = @income_entries.by_income_period(params[:income_year].to_i, params[:income_month].to_i)
    elsif params[:from_date].present? && params[:to_date].present?
      @income_entries = @income_entries.by_income_date_range(Date.parse(params[:from_date]), Date.parse(params[:to_date]))
    end
    
    # Filter by status
    if params[:status].present?
      @income_entries = @income_entries.where(status: params[:status])
    end
    
    # Filter by source_type (e.g., 'CamBill', 'AccountingInvoice')
    if params[:source_type].present?
      @income_entries = @income_entries.where(source_type: params[:source_type])
    end
    
    render json: @income_entries.as_json(
      include: {
        unit: { only: [:id, :name, :unit_number, :owner_name] },
        user: { only: [:id, :first_name, :last_name] }
      }
    )
  end

  # GET /income_entries/:id.json
  def show
    render json: @income_entry.as_json(include: {
      unit: { only: [:id, :name, :unit_number, :owner_name] },
      user: { only: [:id, :first_name, :last_name] },
      journal_entry: { only: [:id, :entry_number, :entry_date, :total_amount] }
    })
  end

  # POST /income_entries.json
  def create
    @income_entry = @site.income_entries.build(income_entry_params)
    @income_entry.user_id = @user.id if @user
    
    if @income_entry.save
      # Create journal entry if accounting integration is enabled
      create_journal_entry(@income_entry) if params[:create_journal_entry]
      
      render json: {
        success: true,
        message: "Income entry created successfully",
        income_entry: @income_entry
      }, status: :created
    else
      render json: {
        success: false,
        message: "Failed to create income entry",
        errors: @income_entry.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /income_entries/:id.json
  def update
    if @income_entry.update(income_entry_params)
      render json: {
        success: true,
        message: "Income entry updated successfully",
        income_entry: @income_entry
      }
    else
      render json: {
        success: false,
        message: "Failed to update income entry",
        errors: @income_entry.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /income_entries/:id.json
  def destroy
    @income_entry.destroy
    render json: {
      success: true,
      message: "Income entry deleted successfully"
    }
  end

  # GET /income_entries/reconciliation_report.json
  # Compare Total CAM Bills Raised vs Income Received
  def reconciliation_report
    from_date = params[:from_date]&.to_date || 6.months.ago.to_date
    to_date = params[:to_date]&.to_date || Date.today
    
    # Total CAM Bills Raised
    total_cam_bills = @site.cam_bills
      .where(bill_date: from_date..to_date)
      .sum(:total_amount)
    
    # Total CAM Bills with Interest
    total_cam_with_interest = @site.cam_bills
      .where(bill_date: from_date..to_date)
      .sum('total_amount + COALESCE(due_amount_interst, 0)')
    
    # Total Income Received (all sources)
    total_income = @site.income_entries
      .where(received_date: from_date..to_date, status: 'received')
      .sum(:amount)
    
    # Income specifically from CAM Bills
    cam_bill_income = @site.income_entries
      .where(source_type: 'CamBill', received_date: from_date..to_date, status: 'received')
      .sum(:amount)
    
    # Outstanding Amount
    outstanding = total_cam_with_interest - cam_bill_income
    
    # Group by month
    monthly_data = @site.cam_bills
      .where(bill_date: from_date..to_date)
      .select("DATE_FORMAT(bill_date, '%Y-%m') as month, 
               SUM(total_amount) as billed,
               SUM(total_amount + COALESCE(due_amount_interst, 0)) as billed_with_interest")
      .group("DATE_FORMAT(bill_date, '%Y-%m')")
      .order("month DESC")
    
    # Add income received per month
    monthly_income = @site.income_entries
      .where(source_type: 'CamBill', received_date: from_date..to_date, status: 'received')
      .select("DATE_FORMAT(received_date, '%Y-%m') as month, SUM(amount) as received")
      .group("DATE_FORMAT(received_date, '%Y-%m')")
      .index_by(&:month)
    
    # Merge monthly data
    monthly_report = monthly_data.map do |data|
      month = data.month
      income_data = monthly_income[month]
      
      {
        month: month,
        billed: data.billed.to_f,
        billed_with_interest: data.billed_with_interest.to_f,
        received: income_data&.received&.to_f || 0.0,
        outstanding: (data.billed_with_interest.to_f - (income_data&.received&.to_f || 0.0))
      }
    end
    
    # Payment mode breakdown
    payment_modes = @site.income_entries
      .where(received_date: from_date..to_date, status: 'received')
      .group(:payment_mode)
      .sum(:amount)
    
    # Unit-wise outstanding
    unit_outstanding = @site.cam_bills
      .where(bill_date: from_date..to_date)
      .joins(:unit)
      .joins("LEFT JOIN users ON users.unit_id = units.id AND users.user_type = 'Owner'")
      .select("units.id as unit_id,
               units.name as unit_name,
               CONCAT(COALESCE(users.firstname, ''), ' ', COALESCE(users.lastname, '')) as owner_name,
               SUM(cam_bills.total_amount + COALESCE(cam_bills.due_amount_interst, 0)) as total_billed")
      .group("units.id, units.name, users.firstname, users.lastname")
    
    # Get income per unit
    unit_income = @site.income_entries
      .where(source_type: 'CamBill', received_date: from_date..to_date, status: 'received')
      .group(:unit_id)
      .sum(:amount)
    
    # Merge unit data
    unit_report = unit_outstanding.map do |data|
      {
        unit_id: data.unit_id,
        unit_name: data.unit_name,
        owner_name: data.owner_name&.strip,
        total_billed: data.total_billed.to_f,
        total_received: unit_income[data.unit_id]&.to_f || 0.0,
        outstanding: data.total_billed.to_f - (unit_income[data.unit_id]&.to_f || 0.0)
      }
    end.sort_by { |u| -u[:outstanding] }
    
    render json: {
      summary: {
        total_cam_bills_raised: total_cam_bills.to_f,
        total_with_interest: total_cam_with_interest.to_f,
        total_income_received: total_income.to_f,
        cam_bill_income: cam_bill_income.to_f,
        outstanding_amount: outstanding.to_f,
        collection_percentage: total_cam_with_interest > 0 ? ((cam_bill_income.to_f / total_cam_with_interest.to_f) * 100).round(2) : 0
      },
      monthly_report: monthly_report,
      payment_modes: payment_modes,
      unit_outstanding: unit_report,
      date_range: {
        from: from_date,
        to: to_date
      }
    }
  end

  private

  def set_site
    @site = @user&.site
    @site ||= Site.find(params[:site_id]) if params[:site_id].present?
    @site ||= Site.find_by(id: request.headers['Site-Id']) if request.headers['Site-Id'].present?
  end

  def validate_site
    unless @site
      render json: {
        success: false,
        message: "Site not found. Please provide site_id parameter or ensure user is authenticated."
      }, status: :unprocessable_entity
    end
  end

  def set_income_entry
    @income_entry = IncomeEntry.find(params[:id])
  end

  def income_entry_params
    params.require(:income_entry).permit(
      :source_type,
      :source_id,
      :unit_id,
      :amount,
      :invoice_number,
      :received_date,
      :payment_mode,
      :reference_number,
      :status,
      :notes,
      :income_month,
      :income_year
    )
  end
  
  def create_journal_entry(income_entry)
    # Ensure required ledgers exist before creating journal entry
    bank_ledger = Ledger.find_by(site_id: @site.id, ledger_type: 'asset', name: 'Bank Account')
    income_ledger = Ledger.find_by(site_id: @site.id, ledger_type: 'income', name: 'CAM Income')

    unless bank_ledger && income_ledger
      Rails.logger.error("Missing ledgers for IncomeEntry ##{income_entry.id}: bank_ledger=#{bank_ledger&.id.inspect}, income_ledger=#{income_ledger&.id.inspect}")
      return
    end

    # Create accounting journal entry for income
    journal = JournalEntry.create!(
      site_id: income_entry.site_id,
      entry_date: income_entry.received_date,
      entry_type: 'receipt',
      narration: "Income received - #{income_entry.source_type} #{income_entry.invoice_number}",
      created_by_id: @user&.id
    )
    
    # Debit: Bank/Cash Account
    journal.journal_entry_lines.create!(
      ledger_id: bank_ledger.id,
      debit: income_entry.amount,
      credit: 0,
      description: "Payment received via #{income_entry.payment_mode}"
    )
    
    # Credit: Income Account
    journal.journal_entry_lines.create!(
      ledger_id: income_ledger.id,
      debit: 0,
      credit: income_entry.amount,
      description: "Income from #{income_entry.source_type}"
    )
    
    income_entry.update(journal_entry_id: journal.id)
  end
end
