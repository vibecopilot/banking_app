class AccountingInvoicesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_accounting_invoice, only: %i[show edit update destroy send_invoice add_payment download_pdf]
  helper :tax_invoice

  # GET /accounting_invoices or /accounting_invoices.json
  def index
    @q = AccountingInvoice.for_site(@user.current_site_id)
      .includes(:unit, :user, :vendor, :accounting_invoice_items, :accounting_payments)
      .ransack(params[:q])
    # Apply filters
    @q.status_eq = params[:status] if params[:status].present?
    @q.invoice_type_eq = params[:invoice_type] if params[:invoice_type].present?
    @q.unit_id_eq = params[:unit_id] if params[:unit_id].present?
    @accounting_invoices = @q.result
      .order(invoice_date: :desc, created_at: :desc)
      .paginate(page: params[:page], per_page: params[:per_page] || 50)
    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /accounting_invoices/1 or /accounting_invoices/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end
def preview
  @invoice = AccountingInvoice.find(params[:id])
  @billing_config = BillingConfiguration.find_by(site_id: @invoice.site_id)
  render template: "accounting_invoices/tax_invoice_pdf", layout: false
end
  # GET /accounting_invoices/new
  def new
    @accounting_invoice = AccountingInvoice.new
    @accounting_invoice.invoice_date = Date.current
    @accounting_invoice.due_date = Date.current + 30.days
    @accounting_invoice.accounting_invoice_items.build
  end

  # GET /accounting_invoices/1/edit
  def edit
  end

  # POST /accounting_invoices or /accounting_invoices.json
  def create
    @accounting_invoice = AccountingInvoice.new(accounting_invoice_params)
    @accounting_invoice.site_id = @user.current_site_id
    @accounting_invoice.created_by = @user

    respond_to do |format|
      if @accounting_invoice.save
        # Create payment record if payment data provided
        if params[:payment_data].present? && params[:payment_data][:payment_mode].present?
          create_payment_record(@accounting_invoice, params[:payment_data])
        end
        
        format.html { redirect_to accounting_invoices_path, notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @accounting_invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @accounting_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounting_invoices/1 or /accounting_invoices/1.json
  def update
    if @accounting_invoice.status == 'paid'
      respond_to do |format|
        format.html { redirect_to accounting_invoices_path, alert: 'Cannot edit a paid invoice.' }
        format.json { render json: { error: 'Cannot edit a paid invoice' }, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @accounting_invoice.update(accounting_invoice_params)
        format.html { redirect_to accounting_invoices_path, notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @accounting_invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @accounting_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_invoices/1 or /accounting_invoices/1.json
  def destroy
    if @accounting_invoice.status == 'paid' || @accounting_invoice.accounting_payments.any?
      respond_to do |format|
        format.html { redirect_to accounting_invoices_path, alert: 'Cannot delete an invoice with payments.' }
        format.json { render json: { error: 'Cannot delete an invoice with payments' }, status: :unprocessable_entity }
      end
      return
    end

    @accounting_invoice.destroy
    respond_to do |format|
      format.html { redirect_to accounting_invoices_url, notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /accounting_invoices/1/send_invoice
  def send_invoice
    if @accounting_invoice.mark_as_sent!
      respond_to do |format|
        format.html { redirect_to accounting_invoices_path, notice: 'Invoice was successfully sent.' }
        format.json { render :show, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to accounting_invoices_path, alert: 'Failed to send invoice.' }
        format.json { render json: { error: 'Failed to send invoice' }, status: :unprocessable_entity }
      end
    end
  end

  # POST /accounting_invoices/1/add_payment
  def add_payment
    payment_amount = params[:amount].to_f
    payment_type = @accounting_invoice.invoice_type.to_s == 'vendor_bill' ? 'paid' : 'received'
    payment_attrs = {
      payment_date: params[:payment_date] || Date.current,
      payment_mode: params[:payment_mode] || 'bank_transfer',
      reference_number: params[:reference_number],
      notes: params[:notes],
      payment_type: payment_type,
      payment_number: nil, # Will be auto-generated
      received_by_id: (payment_type == 'received' ? @user.id : nil),
      vendor_id: (@accounting_invoice.vendor_id if payment_type == 'paid'),
      created_by_id: @user.id
    }

    if @accounting_invoice.add_payment(payment_amount, payment_attrs)
      respond_to do |format|
        format.html { redirect_to @accounting_invoice, notice: 'Payment was successfully added.' }
        format.json { render :show, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to @accounting_invoice, alert: 'Failed to add payment.' }
        format.json { render json: { error: 'Failed to add payment' }, status: :unprocessable_entity }
      end
    end
  end

  # GET /accounting_invoices/:id/download_pdf
  def download_pdf
    @invoice = @accounting_invoice
    @billing_config = BillingConfiguration.find_by(site_id: @invoice.site_id)

    # Render the HTML template to a string (force HTML format)
    html_content = render_to_string(
      template: 'accounting_invoices/tax_invoice_pdf',
      layout: false,
      formats: [:html]
    )

    # Write HTML to a temp file
    html_file = Tempfile.new(['invoice', '.html'])
    html_file.write(html_content)
    html_file.close

    pdf_file = Tempfile.new(['invoice', '.pdf'])
    pdf_file.close

    # Use headless Chrome to convert HTML → PDF
    chrome_path = '/usr/bin/google-chrome'
    cmd = "#{chrome_path} --headless --disable-gpu --no-sandbox --print-to-pdf=#{pdf_file.path} --no-pdf-header-footer #{html_file.path}"
    system(cmd)

    if File.exist?(pdf_file.path) && File.size(pdf_file.path) > 0
      pdf_data = File.binread(pdf_file.path)
      send_data pdf_data,
                filename: "#{@invoice.invoice_number || 'tax_invoice'}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
    else
      render json: { error: 'PDF generation failed' }, status: :internal_server_error
    end
  ensure
    html_file&.unlink
    pdf_file&.unlink
  end

  # GET /accounting_invoices/overdue
  def overdue
    @accounting_invoices = AccountingInvoice.for_site(@user.current_site_id)
      .overdue
      .includes(:unit, :user)
      .order(due_date: :asc)
      .paginate(page: params[:page], per_page: params[:per_page] || 50)
    
    respond_to do |format|
      format.html { render :index }
      format.json { render :index }
    end
  end

  # GET /accounting_invoices/by_unit
  def by_unit
    unit_id = params[:unit_id]
    @accounting_invoices = AccountingInvoice.for_site(@user.current_site_id)
      .for_unit(unit_id)
      .includes(:accounting_invoice_items, :accounting_payments)
      .order(invoice_date: :desc)
      .paginate(page: params[:page], per_page: params[:per_page] || 50)
    
    respond_to do |format|
      format.json { render :index }
    end
  end

  # GET /accounting_invoices/find_by_number.json
  # Params:
  #   - invoice_number: exact invoice number to search for
  # Returns the invoice for the current site along with its unit (including building_id and floor_id)
  def find_by_number
    number = params[:invoice_number].to_s.strip

    if number.blank?
      render json: { error: 'invoice_number is required' }, status: :bad_request
      return
    end

    @accounting_invoice = AccountingInvoice.for_site(@user.current_site_id)
      .includes(unit: [:building, :floor])
      .find_by(invoice_number: number)

    if @accounting_invoice
      render json: @accounting_invoice.as_json(
        include: {
          unit: { only: [:id, :name, :unit_number, :building_id, :floor_id] }
        }
      )
    else
      render json: { error: 'Invoice not found' }, status: :not_found
    end
  end

  def create_payment_record(invoice, payment_data)
    # Create accounting payment with auto-filled fields from current context
    payment = invoice.accounting_payments.build(
      site_id: @user.current_site_id,
      created_by_id: @user.id,
      received_by_id: @user.id,
      accounting_invoice_id: invoice.id,
      unit_id: invoice.unit_id,
      payment_date: Date.current,
      payment_type: 'received', # For invoices, we're recording payment received
      payment_mode: payment_data[:payment_mode],
      reference_number: payment_data[:reference_number],
      amount: payment_data[:amount].to_f
    )
    
    if payment.save
      Rails.logger.info("Payment created successfully for invoice #{invoice.id}")
      
      # Auto-create income entry for the payment
      create_income_entry_from_invoice_payment(invoice, payment)
    else
      Rails.logger.error("Failed to create payment: #{payment.errors.full_messages.join(', ')}")
    end
  end

  # Auto-create income entry when payment is recorded against invoice
  def create_income_entry_from_invoice_payment(invoice, payment)
    # Check if income entry already exists for this payment to avoid duplicates
    existing_entry = IncomeEntry.find_by(
      source_type: 'Invoice Payment',
      source_id: invoice.id,
      amount: payment.amount,
      invoice_number: invoice.invoice_number
    )
    
    if existing_entry
      Rails.logger.info("Income entry already exists for invoice #{invoice.id} payment - skipping")
      return
    end
    
    income_entry = IncomeEntry.new(
      site_id: invoice.site_id || @user.current_site_id,
      unit_id: invoice.unit_id,
      source_type: 'Invoice Payment',
      source_id: invoice.id,
      amount: payment.amount,
      invoice_number: invoice.invoice_number,
      received_date: payment.payment_date,
      payment_mode: payment.payment_mode,
      reference_number: payment.reference_number,
      user_id: @user.id,
      status: 'received',
      income_month: invoice.income_month,
      income_year: invoice.income_year,
      notes: "Auto-created from invoice ##{invoice.invoice_number} payment"
    )
    
    if income_entry.save
      Rails.logger.info("Income entry auto-created for invoice #{invoice.id} payment")
    else
      Rails.logger.error("Failed to create income entry: #{income_entry.errors.full_messages.join(', ')}")
    end
  end

  private

  def set_accounting_invoice
    @accounting_invoice = AccountingInvoice.find(params[:id])
  end

  def accounting_invoice_params
    params.require(:accounting_invoice).permit(
      :invoice_date, :due_date, :unit_id, :user_id, :vendor_id, :invoice_type,
      :notes, :terms_and_conditions, :status, :invoice_number, :unit_no, :source_type,
      :customer_name, :customer_email, :customer_address, :gst_no, :gst_input_value,
      :bank_account, :bank_ifsc, :bank_aic,
      :gst_reverse_charge, :place_of_supply, :state, :state_code,
      :income_month, :income_year,
      accounting_invoice_items_attributes: [
        :id, :description, :ledger_id, :quantity, :unit_price, :tax_rate_id, :item_type, :notes,
        :s_no, :service_description, :service_details, :hsn_sac_code, :rate,
        :taxable_value, :cgst_rate, :cgst_amount, :sgst_rate, :sgst_amount,
        :igst_rate, :igst_amount, :total, :gst_type, :_destroy
      ]
    )
  end
end
