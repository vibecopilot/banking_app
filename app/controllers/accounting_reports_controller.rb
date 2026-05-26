class AccountingReportsController < ApplicationController
  include UserExt
  layout 'basic'
  skip_before_action :verify_authenticity_token, only: [:import_expenses_mis, :import_income_mis, :cam_statement_pdf, :cam_statement_preview]
  before_action :authenticate_user!, if: :check_user, unless: :skip_devise_auth?
  before_action :api_user
  before_action :set_user
  before_action :set_date_range

  # GET /accounting_reports/trial_balance
  def trial_balance
    # binding.pry
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    @ledgers = Ledger.for_site(@user.current_site_id)
    .active
    .includes(:account_group)
    .order('account_groups.group_type ASC, ledgers.code ASC')
    @report_data = []
    total_debit = 0
    total_credit = 0
    @ledgers.each do |ledger|
      balance = ledger.balance_as_on(@to_date)
      next if balance.zero?
      entry = {
        ledger_id: ledger.id,
        ledger_code: ledger.code,
        ledger_name: ledger.name,
        unit_name: ledger.unit&.name,
        account_group: ledger.account_group.name,
        group_type: ledger.account_group.group_type,
        balance: balance.abs,
        side: balance >= 0 ? (ledger.debit_nature? ? 'debit' : 'credit') : (ledger.debit_nature? ? 'credit' : 'debit')
      }
      entry[:side] == 'debit' ? total_debit += entry[:balance] : total_credit += entry[:balance]
      @report_data << entry
    end
    @totals = {
      total_debit: total_debit,
      total_credit: total_credit,
      difference: (total_debit - total_credit).abs
    }
    # binding.pry
    respond_to do |format|
      format.html
      format.json { render json: { report_data: @report_data, totals: @totals, from_date: @from_date, to_date: @to_date } }
    end
  end

  # GET /accounting_reports/balance_sheet
  def balance_sheet
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil
    @assets = get_balance_by_group_type('asset')
    @liabilities = get_balance_by_group_type('liability')
    @equity = get_balance_by_group_type('equity')
    @total_assets = @assets.sum { |g| g[:balance] }
    @total_liabilities = @liabilities.sum { |g| g[:balance] }
    @total_equity = @equity.sum { |g| g[:balance] }
    @report_data = {
      assets: @assets,
      liabilities: @liabilities,
      equity: @equity,
      total_assets: @total_assets,
      total_liabilities: @total_liabilities,
      total_equity: @total_equity,
      total_liabilities_and_equity: @total_liabilities + @total_equity
    }

    respond_to do |format|
      format.html
      format.json { render json: @report_data.merge(as_on_date: @to_date) }
    end
  end

  # GET /accounting_reports/profit_and_loss
  def profit_and_loss
    #binding.pry
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil
    @income = get_balance_by_group_type('income')
    @expenses = get_balance_by_group_type('expense')
    @total_income = @income.sum { |g| g[:balance] }
    @total_expenses = @expenses.sum { |g| g[:balance] }
    @net_profit = @total_income - @total_expenses
    @report_data = {
      income: @income,
      expenses: @expenses,
      total_income: @total_income,
      total_expenses: @total_expenses,
      net_profit: @net_profit
    }
    respond_to do |format|
      format.html
      format.json { render json: @report_data.merge(from_date: @from_date, to_date: @to_date) }
    end
  end

  # GET /accounting_reports/ledger_statement
  def ledger_statement
    #binding.pry
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    ledger_id = params[:ledger_id]
    unless ledger_id
      respond_to do |format|
        format.html { redirect_to ledgers_path, alert: 'Please select a ledger' }
        format.json { render json: { error: 'ledger_id is required' }, status: :unprocessable_entity }
      end
      return
    end

    @ledger = Ledger.find(ledger_id)
    @opening_balance = @ledger.balance_as_on(@from_date - 1.day)

    @transactions = @ledger.journal_entry_lines
    .joins(:journal_entry)
    .where('journal_entries.entry_date BETWEEN ? AND ?', @from_date, @to_date)
    .where('journal_entries.status = ?', 'posted')
    .includes(:journal_entry)
    .order('journal_entries.entry_date ASC, journal_entries.id ASC')
    running_balance = @opening_balance
    @statement = []

    @transactions.each do |line|
      if @ledger.debit_nature?
        running_balance += (line.debit? ? line.amount : -line.amount)
      else
        running_balance += (line.credit? ? line.amount : -line.amount)
      end
      @statement << {
        date: line.journal_entry.entry_date,
        entry_number: line.journal_entry.entry_number,
        description: line.description || line.journal_entry.narration,
        debit: line.debit? ? line.amount : 0,
        credit: line.credit? ? line.amount : 0,
        balance: running_balance
      }
    end

    @closing_balance = running_balance
    @debit_total = @statement.sum { |row| row[:debit].to_d }
    @credit_total = @statement.sum { |row| row[:credit].to_d }
    @net_movement = @ledger.debit_nature? ? (@debit_total - @credit_total) : (@credit_total - @debit_total)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          ledger: {
            id: @ledger.id,
            name: @ledger.name,
            code: @ledger.code
          },
          opening_balance: @opening_balance,
          closing_balance: @closing_balance,
          debit_total: @debit_total,
          credit_total: @credit_total,
          net_movement: @net_movement,
          transactions: @statement,
          from_date: @from_date,
          to_date: @to_date
        }
      end
    end
  end


  # GET /accounting_reports/unit_statement
  def unit_statement
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    unit_id = params[:unit_id]
    unless unit_id
      respond_to do |format|
        format.html { redirect_to units_path, alert: 'Please select a unit' }
        format.json { render json: { error: 'unit_id is required' }, status: :unprocessable_entity }
      end
      return
    end

    @unit = Unit.find(unit_id)

    # Get all invoices for the unit
    @invoices = AccountingInvoice.for_unit(unit_id)
    .where('invoice_date BETWEEN ? AND ?', @from_date, @to_date)
    .includes(:accounting_invoice_items, :accounting_payments)
    .order(invoice_date: :asc)

    # Get all payments for the unit
    @payments = AccountingPayment.for_unit(unit_id)
    .where('payment_date BETWEEN ? AND ?', @from_date, @to_date)
    .includes(:accounting_invoice)
    .order(payment_date: :asc)

    @total_invoiced = @invoices.sum(:total_amount)
    @total_paid = @payments.sum(:amount)
    @outstanding_balance = @invoices.sum(:balance_amount)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          unit: {
            id: @unit.id,
            name: @unit.name,
            building: @unit.building&.name,
            floor: @unit.floor&.name
          },
          invoices: @invoices.map { |inv| {
              id: inv.id,
              invoice_number: inv.invoice_number,
              invoice_date: inv.invoice_date,
              invoice_type: inv.invoice_type,
              total_amount: inv.total_amount,
              paid_amount: inv.paid_amount,
              balance_amount: inv.balance_amount,
              status: inv.status
          }},
          payments: @payments.map { |pmt| {
              id: pmt.id,
              payment_number: pmt.payment_number,
              payment_date: pmt.payment_date,
              amount: pmt.amount,
              payment_mode: pmt.payment_mode,
              invoice_number: pmt.accounting_invoice&.invoice_number
          }},
          summary: {
            total_invoiced: @total_invoiced,
            total_paid: @total_paid,
            outstanding_balance: @outstanding_balance
          },
          from_date: @from_date,
          to_date: @to_date
        }
      end
    end
  end

  def unit_statement_pdf
    unit_statement_data
    company_data = {
      company_name: @company_details.company_name,
      address: @company_details.address,
      gst_number: @company_details.gst_number,
      pan_number: @company_details.pan_number,
      city: @company_details.city,
      state: @company_details.state,
      pincode: @company_details.pincode,
      email: @company_details.email,
      phone: @company_details.phone,
      website: @company_details.website,
      bank_name: @company_details.bank_name,
      account_number: @company_details.account_number,
      ifsc_code: @company_details.ifsc_code,
      branch_name: @company_details.branch_name,
      terms: @company_details.terms_and_conditions
    }

    pdf = pdf = UnitStatementPdf.new(
      company_data,
      @unit,
      @invoices,
      @payments,
      {
        total_invoiced: @total_invoiced,
        total_paid: @total_paid,
        outstanding_balance: @outstanding_balance
      },
      expense_data,
      @from_date,
      @to_date
    )

    send_data pdf.render,
      filename: "unit_statement_#{@unit.id}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  # GET /accounting_reports/cam_statement_pdf
  # Generates CAM Statement PDF dynamically from backend in the required format
  def cam_statement_pdf
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    unit_id = params[:unit_id]
    unless unit_id
      render json: { error: 'unit_id is required' }, status: :unprocessable_entity
      return
    end

    @unit = Unit.find(unit_id)
    site_id = @unit.site_id

    # Find unit owner through user_sites association
    user_site = UserSite.includes(:user).find_by(unit_id: unit_id, site_id: site_id)
    @unit_owner_name = if user_site&.user
      "#{user_site.user.firstname} #{user_site.user.lastname}".strip
      # binding.pry
    else
      # binding.pry
      'N/A'
    end

    # Fetch CAM unit bills for the date range (unit_id is unique per period, no site_id filter needed)
    bills_scope = CamUnitBill.where(unit_id: unit_id)

    # Handle multi-month and cross-year date ranges
    if @from_date.year != @to_date.year
      conditions = []
      (@from_date.year..@to_date.year).each do |y|
        ms = y == @from_date.year ? @from_date.month : 1
        me = y == @to_date.year ? @to_date.month : 12
        conditions << "(year = #{y} AND month BETWEEN #{ms} AND #{me})"
      end
      bills_scope = bills_scope.where(conditions.join(' OR '))
    else
      bills_scope = bills_scope.where(year: @from_date.year, month: @from_date.month..@to_date.month)
    end

    cam_bills = bills_scope.order(year: :asc, month: :asc)
    advance_maintenance_received = cam_bills.sum(:total_amount).to_f

    # Fetch CAM receipts (payments received for the CAM bills)
    cam_bill_ids = cam_bills.pluck(:id)
    receipts_scope = CamReceipt.where(bill_type: 'CamUnitBill', bill_id: cam_bill_ids)
    receipts_total = receipts_scope.sum(:amount).to_f

    # Get unit CAM config for carpet area allocation
    unit_config = CamUnitConfig.find_by(unit_id: unit_id)
    unit_carpet_area = unit_config&.carpet_area_sqft.to_f
    advance_amount = unit_config&.advance_amount.to_f

    # Get total site income from IncomeEntry (single source of truth)
    # This will be allocated proportionally using unit_share (same as expenses)
    total_site_income = IncomeEntry.where(site_id: site_id)
    .by_income_date_range(@from_date, @to_date)
    .sum(:amount).to_f

    # Apex calculations (30% transfer) - on advance_amount only
    apex_percentage = 30
    apex_contribution = (advance_amount * apex_percentage / 100).to_d

    # Calculate unit's share of expenses based on active days (same as expense allocation page)
    expenses_by_category = {}
    total_expenses_before_mgmt = 0.0

    # Get all unit configs for the site to calculate days-based allocation
    site_unit_ids = Unit.where(site_id: site_id).pluck(:id)
    all_unit_configs = CamUnitConfig.where(unit_id: site_unit_ids)

    total_active_days = 0
    unit_active_days = 0

    all_unit_configs.each do |config|
      cam_start = config.cam_start_date || @from_date
      active_start = [cam_start, @from_date].max
      active_days = active_start <= @to_date ? (@to_date - active_start + 1).to_i : 0
      total_active_days += active_days
      unit_active_days = active_days if config.unit_id.to_s == unit_id.to_s
    end

    unit_share = total_active_days > 0 ? (unit_active_days.to_f / total_active_days) : 0

    # Apply unit's share to income (distributed proportionally, same as expenses)
    allocated_other_income = (total_site_income * unit_share).round(2)

    # Total income = billed amount (from CamUnitBill) + allocated other income
    total_income = advance_maintenance_received + allocated_other_income

    if unit_share > 0
      # Get months in the date range
      start_year = @from_date&.year || Date.current.year
      end_year = @to_date&.year || Date.current.year
      start_month = @from_date&.month || 1
      end_month = @to_date&.month || 12

      # Handle multi-year ranges
      (start_year..end_year).each do |year|
        month_start = (year == start_year) ? start_month : 1
        month_end = (year == end_year) ? end_month : 12

        (month_start..month_end).each do |month|
          # CamMonthlyExpense uses project_id (can be site_id or nil for global expenses)
          cam_expenses = CamMonthlyExpense.where(year: year, month: month)
          .where('project_id = ? OR project_id IS NULL', site_id)

          cam_expenses.group(:category).sum(:amount).each do |category, total_amount|
            allocated_amount = (total_amount.to_f * unit_share).round(2)
            next if allocated_amount <= 0

            expenses_by_category[category] ||= 0.0
            expenses_by_category[category] += allocated_amount
            total_expenses_before_mgmt += allocated_amount
          end
        end
      end

      # Journal Entry expenses (debit lines, exclude GST) - same as unit_cam_statement API
      # Only include expense-type account groups (excludes asset/income/liability debits)
      gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
      je_line_scope = JournalEntryLine
      .joins(:journal_entry, ledger: :account_group)
      .where(journal_entries: { site_id: site_id })
      .merge(JournalEntry.by_expense_date_range(@from_date, @to_date))
      .where(entry_side: 'debit')
      .where(account_groups: { group_type: 'expense' })
      .where.not(account_groups: { name: ['GST Input', 'GST Output'] })
      gst_keywords.each { |kw| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", kw) }

      je_line_scope.group('ledgers.name').sum(:amount).each do |ledger_name, total_amount|
        allocated_amount = (total_amount.to_f * unit_share).round(2)
        next if allocated_amount <= 0

        expenses_by_category[ledger_name] ||= 0.0
        expenses_by_category[ledger_name] += allocated_amount
        total_expenses_before_mgmt += allocated_amount
      end
    end

    # Company data from BillingConfiguration (needed early for management fee calc)
    site = Site.find(site_id)
    billing_config = BillingConfiguration.find_by(site_id: site_id)

    # Management fee from billing config (user-configurable percentage + enable/disable toggle)
    management_fee_percentage = billing_config&.management_fee_percentage.to_f
    management_fee = management_fee_percentage > 0 ? (total_expenses_before_mgmt * management_fee_percentage / 100.0).round(2) : 0

    # Total expenses including management fee
    total_expenses = total_expenses_before_mgmt + management_fee

    # Build expense breakdown array (filter out zero amounts)
    expense_breakdown = expenses_by_category.map do |category, amount|
      { name: category, amount: amount.to_f }
    end.reject { |e| e[:amount].zero? }.sort_by { |e| -e[:amount] }

    # Compute total site expense (pre-allocation) for display
    total_site_expense = total_expenses_before_mgmt + management_fee

    # Add management fee to breakdown if it's non-zero
    if management_fee > 0
      expense_breakdown << { name: "Management Fees @ #{management_fee_percentage}%", amount: management_fee }
    end

    # Fallback: if no expenses found via CamMonthlyExpense/JEL, use CAM bill amount as display item
    if expense_breakdown.empty? && advance_maintenance_received > 0
      expense_breakdown << { name: "CAM Maintenance Charges", amount: advance_maintenance_received }
      total_expenses = advance_maintenance_received
      total_site_expense = advance_maintenance_received
    end

    @company_data = {
      company_name: billing_config&.company_name || site&.name || 'ORGANIZATION',
      address: billing_config&.address,
      city: billing_config&.city,
      state: billing_config&.state,
      pincode: billing_config&.pincode,
      email: billing_config&.email,
      phone: billing_config&.phone,
      website: billing_config&.website,
      gst_number: billing_config&.gst_number,
      pan_number: billing_config&.pan_number,

      bank_name: billing_config&.bank_name,
      account_number: billing_config&.account_number,
      ifsc_code: billing_config&.ifsc_code,
      branch_name: billing_config&.branch_name,
      favouring_name: billing_config&.favouring_name,
      account_type: billing_config&.account_type,
      swift_code: billing_config&.swift_code,
      site_name: site&.name,
      site_code: site&.region
    }

    # Invoice-specific fields
    @bill_number = params[:bill_number].presence || "CAM/#{@unit.name}/#{@from_date.strftime('%b%y')}/#{Time.now.to_i % 10000}"
    @due_date = params[:due_date].present? ? Date.parse(params[:due_date]) : Date.today + 15.days
    @receipt_number = params[:receipt_number].presence || "RCP/#{Date.today.year}/#{Time.now.to_i % 100000}"

    # Prepare report data for PDF
    @report_data = {
      unit: {
        flat_no: @unit.name,
        carpet_area: unit_carpet_area,
        advance_amount: advance_amount,
        share_percentage: (unit_share * 100).round(2)
      },
      income: {
        advance_maintenance_received: advance_maintenance_received > 0 ? advance_maintenance_received : advance_amount,
        other_income: allocated_other_income,
        total_income: total_income,
        receipts_total: receipts_total
      },
      apex: {
        contribution_percentage: apex_percentage,
        contribution_amount: apex_contribution,
        total_income: advance_amount
      },
      expenses: {
        total: total_expenses,
        total_site: total_site_expense,
        breakdown: expense_breakdown,
        management_fee: management_fee,
        management_fee_percentage: management_fee_percentage
      },
      allocation: {
        unit_active_days: unit_active_days,
        total_active_days: total_active_days,
        unit_share: unit_share
      }
    }

    # Custom remarks from frontend (editable by user)
    @pdf_remarks = [
      params[:remark_1].presence || "Any Debit / Credit of expenses will be adjusted in next statement of expenses.",
      params[:remark_2].presence || "This is a computer generated statement, signature is not required.",
      params[:remark_3].presence || "For queries write to #{@company_data[:email] || 'the management office'}",
      params[:remark_4].presence || "These are consolidated expenses for the period of #{@from_date.strftime('%B %Y')} to #{@to_date.strftime('%B %Y')}.",
    ]

    # Determine which template to use
    use_invoice_template = params[:template].to_s == 'invoice'
    template_name = use_invoice_template ? 'accounting_reports/statement_cam_invoice.html.erb' : 'accounting_reports/cam_statement_pdf.html.erb'

    # Generate PDF or HTML preview based on params
    if params[:preview].present? && params[:preview].to_s == 'true'
      render template: template_name,
        layout: false,
        content_type: 'text/html'
    else
      pdf_filename = use_invoice_template ? "cam_invoice_#{@unit.name.parameterize}_#{@from_date}_#{@to_date}" : "cam_statement_#{@unit.name.parameterize}_#{@from_date}_#{@to_date}"
      render pdf: pdf_filename,
        disposition: 'attachment',
        dpi: 96,
        page_size: 'A4',
      margin: {
        top: 15,
        bottom: 15,
        left: 12,
        right: 12
      },
        template: template_name,
        layout: false,
        formats: :pdf,
        encoding: 'utf8'
    end
  rescue => e
    render json: { error: "PDF generation failed: #{e.message}" }, status: :internal_server_error
  end

  # GET /accounting_reports/unit_statement_detailed
  # Returns comprehensive JSON with all income and expense details for a unit
  def unit_statement_detailed
    unit_statement_data
    @company_data = {
      company_name: @company_details.company_name,
      address: @company_details.address,
      gst_number: @company_details.gst_number,
      pan_number: @company_details.pan_number,
      city: @company_details.city,
      state: @company_details.state,
      pincode: @company_details.pincode,
      email: @company_details.email,
      phone: @company_details.phone,
      website: @company_details.website,
      bank_name: @company_details.bank_name,
      account_number: @company_details.account_number,
      ifsc_code: @company_details.ifsc_code,
      branch_name: @company_details.branch_name,
      terms: @company_details.terms_and_conditions
    }

    # Get unit CAM config for carpet area
    unit_config = CamUnitConfig.find_by(unit_id: @unit.id)

    # Get detailed expense data for the unit
    expenses = build_expense_data

    # Get detailed income data from invoices
    income_details = build_income_data

    # Get CAM bills if any
    cam_bills = CamUnitBill.where(unit_id: @unit.id)
    .where('created_at BETWEEN ? AND ?', @from_date, @to_date)
    .order(year: :desc, month: :desc)

    # Get CAM receipts through bills (receipts are linked via bill_type/bill_id polymorphic)
    cam_bill_ids = CamUnitBill.where(unit_id: @unit.id).pluck(:id)
    cam_receipts = if cam_bill_ids.any?
      CamReceipt.where(bill_type: 'CamUnitBill', bill_id: cam_bill_ids, date: @from_date..@to_date)
      .order(date: :desc)
    else
      CamReceipt.none
    end

    # Calculate totals
    total_expenses = expenses.sum { |e| e[:amount].to_f }
    total_income = income_details.sum { |i| i[:amount].to_f }

    # Group expenses by category for summary
    expenses_by_category = expenses.group_by { |e| e[:category] }
    .transform_values { |items| items.sum { |i| i[:amount].to_f }.round(2) }

    # Group income by category for summary
    income_by_category = income_details.group_by { |i| i[:category] }
    .transform_values { |items| items.sum { |i| i[:amount].to_f }.round(2) }

    respond_to do |format|
      format.html { render :unit_statement }
      format.json do
        render json: {
          company_details: @company_details,
          unit: {
            id: @unit.id,
            name: @unit.name,
            building: @unit.building&.name,
            floor: @unit.floor&.name,
            carpet_area: unit_config&.carpet_area_sqft.to_f,
            cam_start_date: unit_config&.cam_start_date,
            owner: @unit.user&.name || [@unit.user&.firstname, @unit.user&.lastname].compact.join(' ')
          },
          period: {
            from_date: @from_date,
            to_date: @to_date
          },
          summary: {
            total_invoiced: @total_invoiced,
            total_paid: @total_paid,
            outstanding_balance: @outstanding_balance,
            total_expenses: total_expenses,
            total_income: total_income,
            net_balance: (total_income - total_expenses).round(2)
          },
          invoices: @invoices.map { |inv|
            {
              id: inv.id,
              invoice_number: inv.invoice_number,
              invoice_date: inv.invoice_date,
              invoice_type: inv.invoice_type,
              total_amount: inv.total_amount,
              paid_amount: inv.paid_amount,
              balance_amount: inv.balance_amount,
              status: inv.status,
              items: inv.accounting_invoice_items.map { |item|
                {
                  id: item.id,
                  description: item.description,
                  ledger: item.ledger&.name,
                  taxable_value: item.taxable_value,
                  tax_amount: item.tax_amount,
                  total: item.total
                }
              }
            }
          },
          payments: @payments.map { |pmt|
            {
              id: pmt.id,
              payment_number: pmt.payment_number,
              payment_date: pmt.payment_date,
              amount: pmt.amount,
              payment_mode: pmt.payment_mode,
              reference_number: pmt.reference_number,
              invoice_number: pmt.accounting_invoice&.invoice_number
            }
          },
          expenses: expenses,
          expenses_by_category: expenses_by_category,
          income_breakdown: income_details,
          income_by_category: income_by_category,
          cam_bills: cam_bills.map { |bill|
            {
              id: bill.id,
              year: bill.year,
              month: bill.month,
              carpet_area_sqft: bill.carpet_area_sqft,
              total_amount: bill.total_amount,
              status: bill.status
            }
          },
          cam_receipts: cam_receipts.map { |receipt|
            {
              id: receipt.id,
              date: receipt.date,
              amount: receipt.amount,
              bill_id: receipt.bill_id,
              reference_no: receipt.reference_no
            }
          }
        }
      end
    end
  end

  # GET /accounting_reports/receivables_summary
  def receivables_summary
    # binding.pry # Commenting this out for the final version
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    # 1. Aggregates for the top-level cards (Total Invoiced, Total Paid, Total Outstanding)
    @all_invoices = AccountingInvoice.where(site_id: @user.current_site_id, invoice_date: @from_date..@to_date)

    @total_invoiced = @all_invoices.sum(:total_amount)
    @total_paid = @all_invoices.sum(:paid_amount)
    @total_outstanding_global = @all_invoices.sum(:balance_amount)

    # 2. Fetch units that have at least one invoice with a balance > 0
    @units_with_dues = Unit.where(site_id: @user.current_site_id)
    .joins(:accounting_invoices)
    .where('accounting_invoices.balance_amount > 0')
    .distinct
    .includes(:building, :floor, accounting_invoices: :user)

    @summary = []
    @units_with_dues.each do |unit|
      # Using Ruby .select on the included association to prevent N+1 queries
      # Filter for all invoices belonging to this unit with a positive balance
      outstanding_invoices = unit.accounting_invoices.select { |inv| inv.balance_amount > 0 }

      # Filter specifically for invoices where the due_date has passed
      overdue_invoices = outstanding_invoices.select(&:overdue?)

      @summary << {
        unit_id: unit.id,
        unit_name: unit.name,
        building: unit.building&.name,
        floor: unit.floor&.name,
        # Individaul Values (Monetary)
        total_outstanding: outstanding_invoices.sum(&:balance_amount), # Current debt
        invoice_value: outstanding_invoices.sum(&:total_amount),       # Original bill value of unpaid invoices
        overdue_value: overdue_invoices.sum(&:total_amount),           # Value of specifically late invoices

        # Keep track of the oldest debt
        oldest_invoice_date: outstanding_invoices.map(&:invoice_date).min
      }
    end

    # Sort units by the highest debt first
    @summary.sort_by! { |s| -s[:total_outstanding] }

    respond_to do |format|
      format.html
      format.json do
        render json: {
          summary: @summary,
          total_invoiced: @total_invoiced,
          total_paid: @total_paid,
          total_outstanding: @total_outstanding_global
        }
      end
    end
  end

  # GET /accounting_reports/expenses_mis.xlsx
  # Params:
  # - from_date, to_date (optional, defaults to current month)
  # - invoice_type (optional, default: vendor_bill)
  def expenses_mis
    # binding.pry
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    site = Site.find_by(id: @user.current_site_id)
    invoice_type = params[:invoice_type].presence || 'vendor_bill'

    invoices = AccountingInvoice.for_site(@user.current_site_id)
    .where(invoice_date: @from_date..@to_date)
    .where(invoice_type: invoice_type)
    .includes(:vendor, :accounting_invoice_items)
    .order(invoice_date: :asc, id: :asc)

    filename = "expenses_mis_#{@from_date.strftime('%Y%m%d')}_#{@to_date.strftime('%Y%m%d')}.xlsx"

    send_data(
      generate_expenses_mis_xlsx(invoices: invoices, site: site, from_date: @from_date, to_date: @to_date),
      filename: filename,
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )
  end

  # GET /accounting_reports/income_mis.xlsx
  # Params:
  # - from_date, to_date (optional, defaults to current month)
  # - invoice_type (optional, to filter)
  def income_mis
    # binding.pry
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    invoices = AccountingInvoice.for_site(@user.current_site_id)
    .where(invoice_date: @from_date..@to_date)
    .includes(:unit, :user, :accounting_payments, accounting_invoice_items: [:ledger, :tax_rate])
    .order(invoice_date: :asc, id: :asc)

    if params[:invoice_type].present?
      invoices = invoices.where(invoice_type: params[:invoice_type])
    else
      invoices = invoices.where.not(invoice_type: 'vendor_bill')
    end

    filename = "income_mis_#{@from_date.strftime('%Y%m%d')}_#{@to_date.strftime('%Y%m%d')}.xlsx"

    send_data(
      generate_income_mis_xlsx(invoices: invoices, from_date: @from_date, to_date: @to_date),
      filename: filename,
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )
  end

  # GET /accounting_reports/individual_mis.xlsx
  # Params:
  # - year, month (optional; defaults to to_date year/month)
  # - apex_fund (optional numeric; default 0)
  def individual_mis
    # binding.pry
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date   = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    year  = (params[:year].presence || @to_date.year).to_i
    month = (params[:month].presence || @to_date.month).to_i

    apex_fund_default = params[:apex_fund].to_f
    site = Site.find(@user.current_site_id)

    bills = CamUnitBill
    .where(site_id: @user.current_site_id, year: year, month: month)
    .order(:unit_id)

    units = Unit.where(id: bills.pluck(:unit_id)).includes(:building, :floor, :user)
    unit_by_id = units.index_by(&:id)

    #period_from = Date.new(year, month, 1)
    #period_to   = period_from.end_of_month
    period_from = @from_date
    period_to = @to_date

    # 🔹 EXPENSES (exclude GST categories)
    expenses_scope = CamMonthlyExpense
    .where(year: year, month: month, project_id: @user.current_site_id)
    gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
    gst_keywords.each { |keyword| expenses_scope = expenses_scope.where("category NOT LIKE ?", keyword) }
    expenses_by_category = expenses_scope
    .group(:category)
    .sum(:amount)
    .transform_values(&:to_f)
    .reject { |_, v| v.zero? }

    total_area = bills.sum { |b| b.carpet_area_sqft.to_f }
    total_area = 1.0 if total_area <= 0

    # 🔹 RECEIPTS
    receipts_by_bill = CamReceipt
    .where(bill_type: 'CamUnitBill', date: period_from..period_to)
    .group(:bill_id)
    .sum(:amount)
    .transform_values(&:to_f)

    # 🔹 INCOME (ledger-based, category-wise)
    income_by_category = AccountingInvoice
    .for_site(@user.current_site_id)
    .where(invoice_date: period_from..period_to)
    .joins(accounting_invoice_items: :ledger)
    .joins('INNER JOIN account_groups ON account_groups.id = ledgers.account_group_id')
    .where(account_groups: { group_type: 'income' })
    .group('account_groups.name')
    .sum('accounting_invoice_items.amount')
    .transform_values(&:to_f)
    .reject { |_, v| v.zero? }

    # 🔹 Income share per unit
    income_share_by_unit = {}
    bills.each do |bill|
      share = bill.carpet_area_sqft.to_f / total_area
      income_share_by_unit[bill.unit_id] =
        income_by_category.transform_values { |amt| (amt * share).round(2) }
    end

    filename = "individual_mis_#{year}_#{month.to_s.rjust(2, '0')}.xlsx"

    send_data(
      generate_individual_mis_xlsx(
        site: site,
        bills: bills,
        unit_by_id: unit_by_id,
        receipts_by_bill: receipts_by_bill,
        expenses_by_category: expenses_by_category,
        income_by_category: income_by_category,
        income_share_by_unit: income_share_by_unit,
        total_area: total_area,
        apex_fund_default: apex_fund_default
      ),
      filename: filename,
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )
  end


  # POST /accounting_reports/expenses_mis/import
  # Params:
  # - file: XLSX
  # - invoice_type (optional, default: vendor_bill)
  def import_expenses_mis
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    unless @user
      render json: { code: 401, error: 'Not Authorised' }, status: :unauthorized
      return
    end

    file = params[:file]
    unless file.present?
      render json: { success: false, message: 'No file uploaded.' }, status: :bad_request
      return
    end

    unless file.content_type.in?([
                                   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                   'application/vnd.ms-excel'
      ])
      render json: { success: false, message: 'Unsupported file type. Please upload an Excel (XLSX) file.' }, status: :unprocessable_entity
      return
    end

    invoice_type = params[:invoice_type].presence || 'vendor_bill'
    expected_headers = [
      'Sr. no. ', 'Month ', 'Service', 'Site Name', 'Vendor Name', 'Invoice NO.',
      'Invoice Date', 'Amount', 'Tax', 'Total Amount', 'Particular'
    ]

    spreadsheet = Roo::Spreadsheet.open(file.path)
    sheet = spreadsheet.sheet(0)

    headers = sheet.row(1).map { |h| h.to_s.strip }
    if headers != expected_headers.map { |h| h.to_s.strip }
      render json: {
        success: false,
        message: 'Header mismatch. Please use the Expenses MIS format.',
        expected: expected_headers,
        got: headers
      }, status: :unprocessable_entity
      return
    end

    created = 0
    updated = 0
    errors = []

    (2..sheet.last_row).each do |row_idx|
      row = sheet.row(row_idx)
      first_cell = row[0].to_s

      break if first_cell.to_s.strip.downcase.start_with?('total expenses')
      next if first_cell.to_s.strip.blank?

      begin
        service = row[2].to_s.strip
        vendor_name = row[4].to_s.strip
        invoice_number = row[5].to_s.strip
        invoice_date = row[6].respond_to?(:to_date) ? row[6].to_date : Date.parse(row[6].to_s)
        amount = row[7].to_f
        tax = row[8].to_f
        total = row[9].to_f
        particular = row[10].to_s.strip

        if invoice_number.blank?
          errors << { row: row_idx, error: 'Invoice NO. is required' }
          next
        end

        vendor = nil
        if vendor_name.present?
          vendor = Vendor.where('vendor_name = ? OR company_name = ?', vendor_name, vendor_name).first
        end

        inv = AccountingInvoice.find_by(invoice_number: invoice_number)

        if inv && inv.site_id != @user.current_site_id
          errors << { row: row_idx, error: "Invoice #{invoice_number} already exists for another site" }
          next
        end

        is_new = inv.nil?
        inv ||= AccountingInvoice.new
        inv.invoice_number = invoice_number
        inv.invoice_date = invoice_date
        inv.site_id = @user.current_site_id
        inv.created_by_id = @user.id
        inv.invoice_type = invoice_type
        inv.vendor_id = vendor&.id
        inv.notes = particular.presence || service.presence
        inv.subtotal = amount
        inv.tax_amount = tax
        inv.total_amount = total.positive? ? total : (amount + tax)
        inv.status ||= 'draft'

        if inv.save
          inv.accounting_invoice_items.destroy_all
          inv.accounting_invoice_items.create!(
            description: service.presence || 'Expense',
            taxable_value: amount,
            amount: amount,
            tax_amount: tax,
            total: inv.total_amount
          )

          if is_new
            created += 1
          else
            updated += 1
          end
        else
          errors << { row: row_idx, error: inv.errors.full_messages.join(', ') }
        end
      rescue => e
        errors << { row: row_idx, error: e.message }
      end
    end

    render json: {
      success: errors.empty?,
      message: 'Expenses MIS import completed.',
      created: created,
      updated: updated,
      errors: errors
    }
  end

  # POST /accounting_reports/income_mis/import
  # Params:
  # - file: XLSX
  # - invoice_type (optional default: unit_maintenance)
  def import_income_mis
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    unless @user
      render json: { code: 401, error: 'Not Authorised' }, status: :unauthorized
      return
    end

    file = params[:file]
    unless file.present?
      render json: { success: false, message: 'No file uploaded.' }, status: :bad_request
      return
    end

    unless file.content_type.in?([
                                   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                   'application/vnd.ms-excel'
      ])
      render json: { success: false, message: 'Unsupported file type. Please upload an Excel (XLSX) file.' }, status: :unprocessable_entity
      return
    end

    invoice_type_default = params[:invoice_type].presence || 'unit_maintenance'
    expected_headers = [
      'Sr. No.', 'Month of Service', 'Invoice Date', 'Invoice No.', 'Customer details',
      'Description of Service', 'Services', 'Taxable Amount', 'Rate', 'CGST', 'SGST',
      'IGST', 'Total', 'Payment mode', 'Payment Details'
    ]

    spreadsheet = Roo::Spreadsheet.open(file.path)
    sheet = spreadsheet.sheet(0)

    headers = sheet.row(1).map { |h| h.to_s.strip }
    if headers != expected_headers.map { |h| h.to_s.strip }
      render json: {
        success: false,
        message: 'Header mismatch. Please use the Income MIS format.',
        expected: expected_headers,
        got: headers
      }, status: :unprocessable_entity
      return
    end

    created = 0
    updated = 0
    item_rows = 0
    errors = []

    invoice_cache = {}

    (2..sheet.last_row).each do |row_idx|
      row = sheet.row(row_idx)
      first_cell = row[0].to_s

      break if first_cell.to_s.strip.downcase.start_with?('total income')
      next if first_cell.to_s.strip.blank?

      begin
        invoice_date = row[2].present? ? (row[2].respond_to?(:to_date) ? row[2].to_date : Date.parse(row[2].to_s)) : nil
        invoice_number = row[3].to_s.strip
        customer_details = row[4].to_s.strip
        description = row[5].to_s.strip
        services = row[6].to_s.strip

        taxable = row[7].to_f
        rate = row[8].to_f
        cgst = row[9].to_f
        sgst = row[10].to_f
        igst = row[11].to_f
        total = row[12].to_f
        payment_mode = row[13].to_s.strip
        payment_details = row[14].to_s.strip

        if invoice_number.blank?
          errors << { row: row_idx, error: 'Invoice No. is required' }
          next
        end
        inv = invoice_cache[invoice_number]
        if inv.nil?
          existing = AccountingInvoice.find_by(invoice_number: invoice_number)
          if existing && existing.site_id != @user.current_site_id
            errors << { row: row_idx, error: "Invoice #{invoice_number} already exists for another site" }
            next
          end
          inv = existing || AccountingInvoice.new
          inv.invoice_number = invoice_number
          inv.invoice_date = invoice_date || Date.current
          inv.site_id = @user.current_site_id
          inv.created_by_id = @user.id
          inv.invoice_type = inv.invoice_type.presence || invoice_type_default
          inv.customer_name = customer_details.presence
          inv.notes = description.presence
          inv.status ||= 'draft'
          if inv.save
            if existing
              inv.accounting_invoice_items.destroy_all
              updated += 1
            else
              created += 1
            end
            invoice_cache[invoice_number] = inv
          else
            errors << { row: row_idx, error: inv.errors.full_messages.join(', ') }
            next
          end
        end
        inv.accounting_invoice_items.create!(
          description: description.presence || services.presence || 'Service',
          service_description: services.presence,
          taxable_value: taxable,
          amount: taxable,
          cgst_amount: cgst,
          sgst_amount: sgst,
          igst_amount: igst,
          tax_amount: (cgst + sgst + igst),
          total: total.positive? ? total : (taxable + cgst + sgst + igst),
          cgst_rate: (igst.positive? ? 0 : rate / 2.0),
          sgst_rate: (igst.positive? ? 0 : rate / 2.0),
          igst_rate: (igst.positive? ? rate : 0)
        )
        item_rows += 1
        if payment_mode.present?
          inv.update_columns(notes: [inv.notes, "Payment: #{payment_mode} #{payment_details}"].compact.join(' | '))
        end
      rescue => e
        errors << { row: row_idx, error: e.message }
      end
    end
    render json: {
      success: errors.empty?,
      message: 'Income MIS import completed.',
      invoices_created: created,
      invoices_updated: updated,
      items_created: item_rows,
      errors: errors
    }
  end

  def import_individual_mis
    file = params[:file]
    raise 'No file uploaded' unless file.present?
    year  = params[:year].to_i
    month = params[:month].to_i
    raise 'Year and Month are required' if year.zero? || month.zero?
    spreadsheet = Roo::Spreadsheet.open(file.path)
    sheet = spreadsheet.sheet(0)
    headers = sheet.row(1).map(&:to_s)
    apex_idx     = headers.index('Apex Fund')
    tot_exp_idx  = headers.index('Total Expenses')
    tot_inc_idx  = headers.index('Total Income')
    expense_categories = headers[(apex_idx + 1)...tot_exp_idx]
    income_categories  = headers[(tot_exp_idx + 1)...tot_inc_idx]
    ActiveRecord::Base.transaction do
      # We use a Set to keep track of categories we've already processed globally
      processed_expense_categories = {}
      processed_income_categories = {}

      (2..sheet.last_row).each do |row_num|
        row_data = Hash[headers.zip(sheet.row(row_num))]

        unit = Unit.find_by(name: row_data['Unit'], site_id: @user.current_site_id)
        next unless unit

        bill = CamUnitBill.find_or_initialize_by(
          site_id: @user.current_site_id,
          unit_id: unit.id,
          year: year,
          month: month
        )
        bill.update!(
          carpet_area_sqft: row_data['Carpet Area'],
          total_amount: row_data['CAM Due']
        )
        expense_categories.each do |category|
          amount = row_data[category].to_f
          next if amount.zero? || processed_expense_categories[category]

          CamMonthlyExpense.find_or_create_by!(
            project_id: @user.current_site_id,
            year: year,
            month: month,
            category: category,
            amount: amount # Adjust this logic if the sheet is unit-share based
          )
          processed_expense_categories[category] = true
        end

        # -------------------------
        # 3️⃣ INCOME (Unit Specific or Global)
        # -------------------------
        income_categories.each do |category|
          amount = row_data[category].to_f
          next if amount.zero?

          # Creating individual invoices for the income items
          invoice = AccountingInvoice.find_or_initialize_by(
            site_id: @user.current_site_id,
            unit_id: unit.id,
            invoice_date: Date.new(year, month, 1),
            invoice_type: 'individual_mis_import'
          )
          invoice.update!(
            total_amount: amount,
            status: 'posted'
          )

          # Clear and recreate items to avoid duplicates on re-import
          invoice.accounting_invoice_items.destroy_all
          invoice.accounting_invoice_items.create!(
            description: category,
            amount: amount,
            taxable_value: amount,
            total: amount
          )
        end
      end
    end

    render json: { success: true, message: 'Individual MIS imported and synced successfully' }
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  # GET /accounting_reports/expenses_mis_template
  # Downloads an XLSX with correct headers + 1 dummy row for import testing.
  def expenses_mis_template

    filename = "expenses_mis_template.xlsx"
    send_data(
      generate_expenses_mis_template_xlsx,
      filename: filename,
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )
  end

  # GET /accounting_reports/income_mis_template
  # Downloads an XLSX with correct headers + 2 dummy rows for import testing.
  def income_mis_template
    filename = "income_mis_template.xlsx"
    send_data(
      generate_income_mis_template_xlsx,
      filename: filename,
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )
  end

  private

  def skip_devise_auth?
    # Skip Devise authentication for actions that use API token authentication
    action_name.to_sym == :cam_statement_pdf
  end

  def generate_expenses_mis_template_xlsx
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Expenses MIS') do |sheet|
      headers = [
        'Sr. no. ', 'Month ', 'Service', 'Site Name', 'Vendor Name', 'Invoice NO.',
        'Invoice Date', 'Amount', 'Tax', 'Total Amount', 'Particular'
      ]
      sheet.add_row(headers)

      # Dummy row (you can edit values and re-upload to import)
      sheet.add_row([
                      1,
                      'Jan-2026',
                      'Security',
                      (@user&.site&.try(:name) || 'My Site'),
                      'SecureForce Pvt Ltd',
                      'EXP-DUMMY-001',
                      Date.current,
                      20000,
                      3600,
                      23600,
                      'January security bill'
      ])
    end

    package.to_stream.read
  end

  def generate_income_mis_template_xlsx
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Income MIS') do |sheet|
      headers = [
        'Sr. No.', 'Month of Service', 'Invoice Date', 'Invoice No.', 'Customer details',
        'Description of Service', 'Services', 'Taxable Amount', 'Rate', 'CGST', 'SGST',
        'IGST', 'Total', 'Payment mode', 'Payment Details'
      ]
      sheet.add_row(headers)

      invoice_no = 'INC-DUMMY-001'
      invoice_date = Date.current

      # Dummy rows (same invoice no, multiple items)
      sheet.add_row([
                      1,
                      'Jan-2026',
                      invoice_date,
                      invoice_no,
                      'Unit 701 - Amit',
                      'CAM Jan',
                      'CAM',
                      5000,
                      18,
                      450,
                      450,
                      0,
                      5900,
                      'UPI',
                      'TXN123'
      ])

      sheet.add_row([
                      2,
                      'Jan-2026',
                      invoice_date,
                      invoice_no,
                      'Unit 701 - Amit',
                      'Parking Jan',
                      'Parking',
                      1000,
                      18,
                      90,
                      90,
                      0,
                      1180,
                      'UPI',
                      'TXN123'
      ])
    end

    package.to_stream.read
  end

  def generate_expenses_mis_xlsx(invoices:, site:, from_date:, to_date:)
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Expenses MIS') do |sheet|
      headers = [
        'Sr. no. ', 'Month ', 'Service', 'Site Name', 'Vendor Name', 'Invoice NO.',
        'Invoice Date', 'Amount', 'Tax', 'Total Amount', 'Particular'
      ]
      sheet.add_row(headers)

      total_amount = 0.0
      total_tax = 0.0
      total_total = 0.0

      invoices.each_with_index do |inv, idx|
        service = inv.accounting_invoice_items.map { |it| it.description.presence }.compact.first
        service ||= inv.invoice_type.to_s.tr('_', ' ').split.map(&:capitalize).join(' ')

        vendor_name = inv.vendor&.vendor_name.presence || inv.vendor&.company_name.presence || inv.vendor&.try(:name)

        particular = inv.notes.presence
        if particular.blank?
          item_descs = inv.accounting_invoice_items.map { |it| it.description.to_s.strip }.reject(&:blank?)
          particular = item_descs.first if item_descs.any?
        end

        amount = inv.subtotal.to_f
        tax = inv.tax_amount.to_f
        total = inv.total_amount.to_f

        total_amount += amount
        total_tax += tax
        total_total += total

        sheet.add_row([
                        idx + 1,
                        inv.invoice_date&.beginning_of_month,
                        service,
                        site&.name,
                        vendor_name,
                        inv.invoice_number,
                        inv.invoice_date,
                        amount,
                        tax,
                        total,
                        particular
        ])
      end

      label = "Total Expenses till #{to_date.strftime('%b., %Y')}"
      sheet.add_row([label, nil, nil, nil, nil, nil, nil, total_amount, total_tax, total_total])
    end

    package.to_stream.read
  end

  def generate_income_mis_xlsx(invoices:, from_date:, to_date:)
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Income MIS') do |sheet|
      headers = [
        'Sr. No.', 'Month of Service', 'Invoice Date', 'Invoice No.', 'Customer details',
        'Description of Service', 'Services', 'Taxable Amount', 'Rate', 'CGST', 'SGST',
        'IGST', 'Total', 'Payment mode', 'Payment Details'
      ]
      sheet.add_row(headers)

      sr = 0
      sum_taxable = 0.0
      sum_cgst = 0.0
      sum_sgst = 0.0
      sum_igst = 0.0
      sum_total = 0.0

      invoices.each do |inv|
        payment = inv.accounting_payments.select { |p| p.payment_type == 'received' }.max_by(&:payment_date)
        payment_mode = payment&.payment_mode
        payment_details = payment&.reference_number

        customer = inv.customer_name.presence
        if customer.blank?
          customer = [
            inv.user&.try(:first_name),
            inv.user&.try(:last_name)
          ].compact.join(' ').strip
        end
        customer = inv.unit&.full_address.presence || inv.unit&.name if customer.blank?

        items = inv.accounting_invoice_items
        items = [nil] if items.blank?

        items.each do |item|
          sr += 1

          desc = item&.description.presence || inv.notes
          service = item&.ledger&.name.presence || inv.invoice_type.to_s.tr('_', ' ').split.map(&:capitalize).join(' ')

          taxable = (item&.taxable_value.presence ? item.taxable_value.to_f : item&.amount.to_f)
          taxable = inv.subtotal.to_f if taxable <= 0 && item.nil?

          igst = item&.igst_amount.to_f
          cgst = item&.cgst_amount.to_f
          sgst = item&.sgst_amount.to_f

          tax_total = (item&.tax_amount.to_f)
          if igst <= 0 && cgst <= 0 && sgst <= 0 && tax_total > 0
            cgst = (tax_total / 2.0)
            sgst = (tax_total / 2.0)
          end

          rate = if item&.igst_rate.present?
            item.igst_rate.to_f
          elsif item&.cgst_rate.present? || item&.sgst_rate.present?
            item.cgst_rate.to_f + item.sgst_rate.to_f
          elsif item&.tax_rate&.rate.present?
            item.tax_rate.rate.to_f
          else
            nil
          end

          total = if item&.total.present?
            item.total.to_f
          elsif item&.total_amount.present?
            item.total_amount.to_f
          else
            (taxable + cgst + sgst + igst)
          end

          sum_taxable += taxable
          sum_cgst += cgst
          sum_sgst += sgst
          sum_igst += igst
          sum_total += total

          sheet.add_row([
                          sr,
                          inv.invoice_date&.beginning_of_month,
                          inv.invoice_date,
                          inv.invoice_number,
                          customer,
                          desc,
                          service,
                          taxable,
                          rate,
                          cgst,
                          sgst,
                          igst,
                          total,
                          payment_mode,
                          payment_details
          ])
        end
      end

      label = "Total Income till #{to_date.strftime('%b., %Y')}"
      sheet.add_row([label, nil, nil, nil, nil, nil, nil, sum_taxable, nil, sum_cgst, sum_sgst, sum_igst, sum_total])
    end

    package.to_stream.read
  end

  def generate_individual_mis_xlsx(
      site:,
      bills:,
      unit_by_id:,
      receipts_by_bill:,
      expenses_by_category:,
      income_by_category:,
      income_share_by_unit:,
      total_area:,
      apex_fund_default:
    )
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Individual MIS') do |sheet|

      expense_categories = expenses_by_category.keys
      income_categories  = income_by_category.keys

      headers = [
        'Sr No', 'Project Name', 'Unit', 'Carpet Area', 'Member Name',
        'CAM Due', 'CAM Received', 'Balance', 'Apex Fund'
      ] +
        expense_categories +
        ['Total Expenses'] +
        income_categories +
        ['Total Income', 'Net Expenses', 'Balance Fund']

      sheet.add_row(headers)

      bills.each_with_index do |bill, idx|
        unit  = unit_by_id[bill.unit_id]
        share = bill.carpet_area_sqft.to_f / total_area

        expense_values = expense_categories.map { |c| (expenses_by_category[c] * share).round(2) }
        income_values  = income_categories.map  { |c| income_share_by_unit[bill.unit_id][c].to_f }

        total_expenses = expense_values.sum.round(2)
        total_income   = income_values.sum.round(2)

        cam_due      = bill.total_amount.to_f
        cam_received = receipts_by_bill[bill.id].to_f
        balance      = (cam_due - cam_received).round(2)

        net_expenses = (total_expenses - total_income).round(2)
        apex_fund    = apex_fund_default.to_f
        balance_fund = (apex_fund - net_expenses).round(2)

        member_name = unit&.user&.name ||
          "#{unit&.user&.firstname} #{unit&.user&.lastname}".strip

        sheet.add_row(
          [
            idx + 1,
            site.name,
            unit&.name,
            bill.carpet_area_sqft.to_f,
            member_name,
            cam_due,
            cam_received,
            balance,
            apex_fund
          ] +
          expense_values +
          [total_expenses] +
          income_values +
          [total_income, net_expenses, balance_fund]
        )
      end
    end

    package.to_stream.read
  end


  def categorize_monthly_expenses(expenses_by_category)
    buckets = {
      electricity: 0.0,
      housekeeping: 0.0,
      security: 0.0,
      mts: 0.0
    }

    expenses_by_category.each do |category, amount|
      key = category.to_s.downcase
      amt = amount.to_f

      if key.include?('electric')
        buckets[:electricity] += amt
      elsif key.include?('house') || key.include?('hk')
        buckets[:housekeeping] += amt
      elsif key.include?('secur')
        buckets[:security] += amt
      elsif key.include?('mts') || key.include?('maint')
        buckets[:mts] += amt
      end
    end

    buckets
  end

  def set_date_range
    #@from_date = params[:from_date] ? Date.parse(params[:from_date]) : Date.current.beginning_of_month
    @from_date = params[:start_date]
    #@to_date = params[:to_date] ? Date.parse(params[:to_date]) : Date.current
    @to_date = params[:end_date]
  end

  def get_balance_by_group_type(group_type)
    groups = AccountGroup.for_site(@user.current_site_id)
    .where(group_type: group_type)
    .includes(:ledgers)
    result = []
    groups.each do |group|
      ledgers_balance = 0

      group.ledgers.for_site(@user.current_site_id).each do |ledger|
        ledgers_balance += ledger.balance_as_on(@to_date).abs
      end

      if ledgers_balance != 0
        result << {
          group_id: group.id,
          group_code: group.code,
          group_name: group.name,
          balance: ledgers_balance
        }
      end
    end
    result
  end

  def unit_statement_data
    @from_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @to_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    site_id = @user.current_site_id
    @company_details = BillingConfiguration.find_by(site_id: site_id)
    @unit = Unit.find(params[:unit_id])
    @invoices = AccountingInvoice.for_unit(params[:unit_id])
    .where('invoice_date BETWEEN ? AND ?', @from_date, @to_date)
    .includes(:accounting_invoice_items, :accounting_payments)
    .order(:invoice_date)
    @payments = AccountingPayment.for_unit(params[:unit_id])
    .where('payment_date BETWEEN ? AND ?', @from_date, @to_date)
    .includes(:accounting_invoice)
    .order(:payment_date)
    @total_invoiced = @invoices.sum(:total_amount)
    @total_paid = @payments.sum(:amount)
    @outstanding_balance = @invoices.sum(:balance_amount)
  end

  # Build expense data for PDF and JSON responses
  def expense_data
    build_expense_data
  end

  # Build detailed expense breakdown for the unit
  def build_expense_data
    expenses = []
    site_id = @user.current_site_id

    # Get expense invoices (vendor bills) allocated to this unit
    vendor_bills = AccountingInvoice.where(unit_id: @unit.id, invoice_type: 'vendor_bill')
    .where('invoice_date BETWEEN ? AND ?', @from_date, @to_date)

    vendor_bills.each do |bill|
      bill.accounting_invoice_items.each do |item|
        # Skip GST-related ledger items
        ledger_name = item.ledger&.name.to_s
        group_name = item.ledger&.account_group&.name.to_s
        next if ledger_name.match?(/cgst|sgst|igst|gst/i) || group_name.match?(/GST Input|GST Output/i)

        # Use base amount (excluding tax) for expenses
        expenses << {
          name: item.description.presence || bill.vendor&.vendor_name || 'Expense',
          amount: item.amount.to_f,
          category: item.ledger&.account_group&.name || 'General',
          date: bill.invoice_date,
          invoice_number: bill.invoice_number,
          type: 'vendor_bill'
        }
      end
    end

    # Get CAM monthly expenses allocated to this unit (pro-rata by carpet area from CamUnitConfig)
    unit_config = CamUnitConfig.find_by(unit_id: @unit.id)
    unit_carpet_area = unit_config&.carpet_area_sqft.to_f

    if unit_carpet_area > 0
      # Total carpet area from all CamUnitConfigs (for pro-rata calculation)
      # Get unit_ids for this site
      site_unit_ids = Unit.where(site_id: site_id).pluck(:id)
      total_site_area = CamUnitConfig.where(unit_id: site_unit_ids).sum(:carpet_area_sqft).to_f
      total_site_area = 1.0 if total_site_area <= 0

      unit_share = unit_carpet_area / total_site_area

      # Get months in the date range
      start_year = @from_date&.year || Date.current.year
      end_year = @to_date&.year || Date.current.year
      start_month = @from_date&.month || 1
      end_month = @to_date&.month || 12

      # Handle multi-year ranges
      (start_year..end_year).each do |year|
        month_start = (year == start_year) ? start_month : 1
        month_end = (year == end_year) ? end_month : 12

        (month_start..month_end).each do |month|
          # CamMonthlyExpense uses project_id (can be site_id or nil for global expenses)
          cam_expenses = CamMonthlyExpense.where(year: year, month: month)
          .where('project_id = ? OR project_id IS NULL', site_id)

          cam_expenses.group(:category).sum(:amount).each do |category, total_amount|
            allocated_amount = (total_amount.to_f * unit_share).round(2)
            next if allocated_amount <= 0

            expenses << {
              name: "#{category} (#{Date::MONTHNAMES[month]} #{year})",
              amount: allocated_amount,
              category: category,
              date: Date.new(year, month, 1),
              type: 'cam_allocation',
              total_expense: total_amount.to_f,
              unit_share_percent: (unit_share * 100).round(2)
            }
          end
        end
      end
    end

    expenses
  end

  # Build detailed income breakdown for the unit
  def build_income_data
    income = []

    @invoices.where.not(invoice_type: 'vendor_bill').each do |inv|
      inv.accounting_invoice_items.each do |item|
        # Skip GST-related ledger items
        ledger_name = item.ledger&.name.to_s
        group_name = item.ledger&.account_group&.name.to_s
        next if ledger_name.match?(/cgst|sgst|igst|gst/i) || group_name.match?(/GST Input|GST Output/i)

        # Use base amount (excluding tax) for income
        amount = item.amount.to_f

        income << {
          name: item.description.presence || inv.invoice_type&.titleize || 'Income',
          amount: amount,
          category: item.ledger&.name || inv.invoice_type&.titleize || 'General',
          date: inv.invoice_date,
          invoice_number: inv.invoice_number,
          paid: inv.paid_amount.to_f,
          balance: inv.balance_amount.to_f
        }
      end
    end

    income
  end

  public

  # GET /accounting_reports/dashboard
  # Returns comprehensive dashboard analytics data for the accounting module
  def dashboard
    site_id = @user.current_site_id
    current_year = Date.current.year
    year_start = Date.new(current_year, 1, 1)
    year_end = Date.new(current_year, 12, 31)

    # Base scopes
    invoices = AccountingInvoice.for_site(site_id)
    payments = AccountingPayment.for_site(site_id)
    journal_entries = JournalEntry.for_site(site_id).posted
    ledgers = Ledger.for_site(site_id).active

    # === Summary Statistics ===
    total_invoices = invoices.count
    total_revenue = invoices.where(status: 'paid').sum(:total_amount)
    pending_amount = invoices.where(status: %w[sent partially_paid]).sum(:balance_amount)
    overdue_invoices = invoices.overdue.count

    # Total Expenses from expense-type ledgers (exclude GST)
    expense_ledger_ids = ledgers.by_group_type('expense').pluck(:id)
    gst_ledger_ids = Ledger.for_site(site_id).active
    .joins(:account_group)
    .where("account_groups.name LIKE '%GST%' OR ledgers.name LIKE '%CGST%' OR ledgers.name LIKE '%SGST%' OR ledgers.name LIKE '%IGST%' OR ledgers.name LIKE '%GST%'")
    .pluck(:id)
    non_gst_expense_ledger_ids = expense_ledger_ids - gst_ledger_ids
    je_total_expenses = JournalEntryLine.joins(:journal_entry)
    .where(journal_entries: { site_id: site_id, status: 'posted' })
    .where(ledger_id: non_gst_expense_ledger_ids, entry_side: 'debit')
    .sum(:amount)

    # CAM Monthly Expenses (manually entered expenses like Salaries, etc.)
    # The monthly_expenses table uses project_id or site_id to identify the site
    cam_expenses_scope = CamMonthlyExpense.where("project_id = :sid OR site_id = :sid", sid: site_id)
    gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
    gst_keywords.each { |keyword| cam_expenses_scope = cam_expenses_scope.where("category NOT LIKE ?", keyword) }
    cam_total_expenses = cam_expenses_scope.sum(:amount)

    total_expenses = je_total_expenses + cam_total_expenses

    summary_stats = {
      total_invoices: total_invoices,
      total_revenue: total_revenue.to_f.round(2),
      pending_amount: pending_amount.to_f.round(2),
      total_expenses: total_expenses.to_f.round(2),
      overdue_invoices: overdue_invoices,
      total_payments: payments.count,
      journal_entries: journal_entries.count,
      active_ledgers: ledgers.count
    }

    # === Recent Items ===
    recent_invoices = invoices.order(invoice_date: :desc, created_at: :desc).limit(5).map do |inv|
      {
        id: inv.id,
        invoice_number: inv.invoice_number,
        customer_name: inv.user&.full_name || inv.unit&.name || inv.vendor&.name,
        total_amount: inv.total_amount.to_f.round(2),
        status: inv.status,
        invoice_date: inv.invoice_date,
        due_date: inv.due_date
      }
    end

    recent_payments = payments.order(payment_date: :desc, created_at: :desc).limit(5).map do |pmt|
      {
        id: pmt.id,
        payment_number: pmt.payment_number,
        payment_mode: pmt.payment_mode,
        amount: pmt.amount.to_f.round(2),
        payment_date: pmt.payment_date,
        payment_type: pmt.payment_type
      }
    end

    recent_journal_entries = journal_entries.order(entry_date: :desc, created_at: :desc).limit(5).map do |je|
      {
        id: je.id,
        entry_number: je.entry_number,
        entry_date: je.entry_date,
        description: je.narration,
        amount: je.total_debit.to_f.round(2),
        status: je.status
      }
    end

    # === Monthly Revenue Trend (Current Year) ===
    monthly_revenue = (1..12).map do |month|
      revenue = AccountingInvoice.for_site(site_id).where(status: 'paid')
      .by_income_period(current_year, month)
      .sum(:total_amount)

      { month: month, month_name: Date::MONTHNAMES[month], revenue: revenue.to_f.round(2) }
    end

    # === Monthly Expenses Trend (Current Year) ===
    # Uses expense_month/expense_year when available, fallback to entry_date
    # Includes both journal entry expenses AND CAM monthly expenses (Salaries, etc.)
    monthly_expenses_data = (1..12).map do |month|
      je_expenses = JournalEntryLine.joins(:journal_entry)
      .where(journal_entries: { site_id: site_id, status: 'posted' })
      .merge(JournalEntry.by_expense_period(current_year, month))
      .where(ledger_id: non_gst_expense_ledger_ids, entry_side: 'debit')
      .sum(:amount)

      cam_month_scope = CamMonthlyExpense.where("project_id = :sid OR site_id = :sid", sid: site_id).where(year: current_year, month: month)
      gst_keywords.each { |keyword| cam_month_scope = cam_month_scope.where("category NOT LIKE ?", keyword) }
      cam_expenses = cam_month_scope.sum(:amount)

      expenses = je_expenses + cam_expenses

      { month: month, month_name: Date::MONTHNAMES[month], expenses: expenses.to_f.round(2) }
    end

    # === Invoice Status Distribution ===
    invoice_status_distribution = invoices.group(:status).count.map do |status, count|
      { status: status, count: count }
    end

    # === Payment Methods Distribution ===
    payment_methods_distribution = payments.group(:payment_mode).count.map do |mode, count|
      { payment_mode: mode || 'other', count: count }
    end

    # === Account Groups Summary ===
    account_groups_summary = AccountGroup.for_site(site_id)
    .group(:group_type)
    .joins(:ledgers)
    .select('account_groups.group_type, SUM(ledgers.current_balance) as total_balance')
    .map do |ag|
      { group_type: ag.group_type, total_balance: ag.total_balance.to_f.round(2) }
    end

    # === Invoices vs Payments (Monthly Comparison) ===
    invoices_vs_payments = (1..12).map do |month|
      month_start = Date.new(current_year, month, 1)
      month_end = month_start.end_of_month

      invoice_total = invoices.where(invoice_date: month_start..month_end).sum(:total_amount)
      payment_total = payments.where(payment_date: month_start..month_end).sum(:amount)

      {
        month: month,
        month_name: Date::MONTHNAMES[month],
        invoiced: invoice_total.to_f.round(2),
        collected: payment_total.to_f.round(2)
      }
    end

    # === Top Customers (by invoice amount) ===
    top_customers = invoices
    .joins("INNER JOIN users ON users.id = accounting_invoices.user_id")
    .where.not(user_id: nil)
    .group("accounting_invoices.user_id, users.firstname")
    .order("SUM(accounting_invoices.total_amount) DESC")
    .limit(10)
    .sum(:total_amount)

    # Combine revenue and expenses for chart
    monthly_trend = (1..12).map do |month|
      {
        month: month,
        month_name: Date::MONTHNAMES[month],
        revenue: monthly_revenue.find { |m| m[:month] == month }[:revenue],
        expenses: monthly_expenses_data.find { |m| m[:month] == month }[:expenses]
      }
    end

    dashboard_data = {
      summary: summary_stats,
      recent_invoices: recent_invoices,
      recent_payments: recent_payments,
      recent_journal_entries: recent_journal_entries,
      analytics: {
        monthly_revenue: monthly_revenue,
        monthly_expenses: monthly_expenses_data,
        monthly_trend: monthly_trend,
        invoice_status_distribution: invoice_status_distribution,
        payment_methods_distribution: payment_methods_distribution,
        account_groups_summary: account_groups_summary,
        invoices_vs_payments: invoices_vs_payments,
        top_customers: top_customers
      },
      filters: {
        current_year: current_year,
        year_start: year_start,
        year_end: year_end
      }
    }

    respond_to do |format|
      format.html
      format.json { render json: dashboard_data }
    end
  end

  # GET /accounting_reports/dashboard_summary
  # Returns only the summary statistics (lightweight version)
  def dashboard_summary
    site_id = @user.current_site_id

    invoices = AccountingInvoice.for_site(site_id)
    payments = AccountingPayment.for_site(site_id)
    journal_entries = JournalEntry.for_site(site_id).posted
    ledgers = Ledger.for_site(site_id).active

    expense_ledger_ids = ledgers.by_group_type('expense').pluck(:id)
    # Exclude GST-related ledgers from expense totals
    gst_ledger_ids = Ledger.for_site(site_id).active
    .joins(:account_group)
    .where("account_groups.name LIKE '%GST%' OR ledgers.name LIKE '%CGST%' OR ledgers.name LIKE '%SGST%' OR ledgers.name LIKE '%IGST%' OR ledgers.name LIKE '%GST%'")
    .pluck(:id)
    non_gst_expense_ledger_ids = expense_ledger_ids - gst_ledger_ids
    total_expenses = JournalEntryLine.joins(:journal_entry)
    .where(journal_entries: { site_id: site_id, status: 'posted' })
    .where(ledger_id: non_gst_expense_ledger_ids, entry_side: 'debit')
    .sum(:amount)

    summary = {
      total_invoices: invoices.count,
      total_revenue: invoices.where(status: 'paid').sum(:total_amount).to_f.round(2),
      pending_amount: invoices.where(status: %w[sent partially_paid]).sum(:balance_amount).to_f.round(2),
      total_expenses: total_expenses.to_f.round(2),
      overdue_invoices: invoices.overdue.count,
      total_payments: payments.count,
      journal_entries: journal_entries.count,
      active_ledgers: ledgers.count
    }

    render json: summary
  end

  # GET /accounting_reports/analytics
  # Returns detailed analytics with optional date range filtering
  def analytics
    site_id = @user.current_site_id
    # Parse date range params (default to current year)
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_year
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_year
    invoices = AccountingInvoice.for_site(site_id).where(invoice_date: start_date..end_date)
    payments = AccountingPayment.for_site(site_id).where(payment_date: start_date..end_date)
    journal_entries = JournalEntry.for_site(site_id).posted.where(entry_date: start_date..end_date)
    ledgers = Ledger.for_site(site_id).active
    expense_ledger_ids = ledgers.by_group_type('expense').pluck(:id)
    # Exclude GST-related ledgers from expense totals
    gst_ledger_ids = Ledger.for_site(site_id).active
    .joins(:account_group)
    .where("account_groups.name LIKE '%GST%' OR ledgers.name LIKE '%CGST%' OR ledgers.name LIKE '%SGST%' OR ledgers.name LIKE '%IGST%' OR ledgers.name LIKE '%GST%'")
    .pluck(:id)
    non_gst_expense_ledger_ids = expense_ledger_ids - gst_ledger_ids

    # GST keywords for excluding GST categories from CAM monthly expenses
    cam_gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']

    # Group by month
    months_in_range = []
    current = start_date.beginning_of_month
    while current <= end_date
      months_in_range << current
      current = current.next_month
    end

    monthly_data = months_in_range.map do |month_start|
      month_end = month_start.end_of_month

      # Use income_month/income_year when available, fallback to invoice_date
      revenue = AccountingInvoice.for_site(site_id).where(status: 'paid')
      .by_income_period(month_start.year, month_start.month)
      .sum(:total_amount)

      # Use expense_month/expense_year when available, fallback to entry_date
      je_expenses = JournalEntryLine.joins(:journal_entry)
      .where(journal_entries: { site_id: site_id, status: 'posted' })
      .merge(JournalEntry.by_expense_period(month_start.year, month_start.month))
      .where(ledger_id: non_gst_expense_ledger_ids, entry_side: 'debit')
      .sum(:amount)

      # CAM Monthly Expenses (manually entered expenses like Salaries, etc.)
      cam_month_scope = CamMonthlyExpense.where("project_id = :sid OR site_id = :sid", sid: site_id)
      .where(year: month_start.year, month: month_start.month)
      cam_gst_keywords.each { |keyword| cam_month_scope = cam_month_scope.where("category NOT LIKE ?", keyword) }
      cam_expenses = cam_month_scope.sum(:amount)

      expenses = je_expenses + cam_expenses

      invoice_total = invoices.where(invoice_date: month_start..month_end).sum(:total_amount)
      payment_total = payments.where(payment_date: month_start..month_end).sum(:amount)
      je_count = journal_entries.where(entry_date: month_start..month_end).count
      je_total = journal_entries.where(entry_date: month_start..month_end).sum(:total_debit)

      {
        month: month_start.month,
        year: month_start.year,
        month_name: month_start.strftime('%b %Y'),
        revenue: revenue.to_f.round(2),
        expenses: expenses.to_f.round(2),
        invoiced: invoice_total.to_f.round(2),
        collected: payment_total.to_f.round(2),
        journal_entries_count: je_count,
        journal_entries_total: je_total.to_f.round(2)
      }
    end

    # Invoice status breakdown
    invoice_status = invoices.group(:status).count.map { |s, c| { status: s, count: c } }

    # Payment mode breakdown
    payment_modes = payments.group(:payment_mode).count.map { |m, c| { mode: m || 'other', count: c } }
    payment_modes_amount = payments.group(:payment_mode).sum(:amount).map { |m, a| { mode: m || 'other', amount: a.to_f.round(2) } }

    # Journal entries by type
    journal_entries_by_type = journal_entries.group(:entry_type).count.map { |t, c| { entry_type: t || 'general', count: c } }
    journal_entries_by_type_amount = journal_entries.group(:entry_type).sum(:total_debit).map { |t, a| { entry_type: t || 'general', amount: a.to_f.round(2) } }

    # Recent journal entries
    recent_journal_entries = journal_entries.order(entry_date: :desc, created_at: :desc).limit(10).map do |je|
      {
        id: je.id,
        entry_number: je.entry_number,
        entry_date: je.entry_date,
        entry_type: je.entry_type,
        narration: je.narration,
        total_debit: je.total_debit.to_f.round(2),
        total_credit: je.total_credit.to_f.round(2),
        status: je.status
      }
    end

    # Top customers
    top_customers = invoices.joins(:user)
    .where.not(user_id: nil)
    .group(:user_id, 'users.firstname')
    .order('sum_total_amount DESC')
    .limit(10)
    .sum(:total_amount)
    .map { |(uid, name), total| { user_id: uid, name: name, total: total.to_f.round(2) } }

    # Account groups
    account_groups = AccountGroup.for_site(site_id)
    .includes(:ledgers)
    .map do |ag|
      balance = ag.ledgers.sum(:current_balance)
      { id: ag.id, name: ag.name, group_type: ag.group_type, balance: balance.to_f.round(2) }
    end

    render json: {
      date_range: { start_date: start_date, end_date: end_date },
      monthly_data: monthly_data,
      invoice_status: invoice_status,
      payment_modes: payment_modes,
      payment_modes_amount: payment_modes_amount,
      journal_entries: {
        by_type: journal_entries_by_type,
        by_type_amount: journal_entries_by_type_amount,
        recent: recent_journal_entries,
        total_count: journal_entries.count,
        total_amount: journal_entries.sum(:total_debit).to_f.round(2)
      },
      top_customers: top_customers,
      account_groups: account_groups,
      totals: {
        total_revenue: invoices.where(status: 'paid').sum(:total_amount).to_f.round(2),
        total_invoiced: invoices.sum(:total_amount).to_f.round(2),
        total_collected: payments.sum(:amount).to_f.round(2),
        total_pending: invoices.sum(:balance_amount).to_f.round(2),
        total_expenses: monthly_data.sum { |m| m[:expenses] },
        total_journal_entries: journal_entries.count,
        total_journal_amount: journal_entries.sum(:total_debit).to_f.round(2)
      }
    }
  end
end
