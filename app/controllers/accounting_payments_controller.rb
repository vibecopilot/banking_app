class AccountingPaymentsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_accounting_payment, only: %i[show edit update destroy]

  # GET /accounting_payments or /accounting_payments.json
  def index
    @q = AccountingPayment.for_site(@user.current_site_id)
      .includes(:unit, :accounting_invoice, :user, :vendor)
      .ransack(params[:q])
    
    # Apply filters
    @q.payment_type_eq = params[:payment_type] if params[:payment_type].present?
    @q.unit_id_eq = params[:unit_id] if params[:unit_id].present?
    
    @accounting_payments = @q.result
      .order(payment_date: :desc, created_at: :desc)
      .paginate(page: params[:page], per_page: params[:per_page] || 50)
    
    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /accounting_payments/1 or /accounting_payments/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  # GET /accounting_payments/new
  def new
    @accounting_payment = AccountingPayment.new
    @accounting_payment.payment_date = Date.current
    @accounting_payment.payment_type = params[:payment_type] || 'received'
    @accounting_payment.accounting_invoice_id = params[:invoice_id] if params[:invoice_id]
  end

  # GET /accounting_payments/1/edit
  def edit
  end

  # POST /accounting_payments or /accounting_payments.json
  def create
    @accounting_payment = AccountingPayment.new(accounting_payment_params)
    @accounting_payment.site_id = @user.current_site_id
    @accounting_payment.created_by = @user
    @accounting_payment.received_by = @user if @accounting_payment.payment_type == 'received'

    respond_to do |format|
      if @accounting_payment.save
        # Auto-create income entry when payment is received
        if @accounting_payment.payment_type == 'received'
          create_income_entry_from_payment(@accounting_payment)
        end
        
        format.html { redirect_to accounting_payments_path, notice: 'Payment was successfully created.' }
        format.json { render :show, status: :created, location: @accounting_payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @accounting_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounting_payments/1 or /accounting_payments/1.json
  def update
    respond_to do |format|
      if @accounting_payment.update(accounting_payment_params)
        format.html { redirect_to accounting_payments_path, notice: 'Payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @accounting_payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @accounting_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_payments/1 or /accounting_payments/1.json
  def destroy
    @accounting_payment.destroy
    respond_to do |format|
      format.html { redirect_to accounting_payments_url, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /accounting_payments/by_invoice
  def by_invoice
    invoice_id = params[:invoice_id]
    @accounting_payments = AccountingPayment.for_site(@user.current_site_id)
      .for_invoice(invoice_id)
      .order(payment_date: :desc)
    
    respond_to do |format|
      format.json { render :index }
    end
  end

  private

  def set_accounting_payment
    @accounting_payment = AccountingPayment.find(params[:id])
  end

  def accounting_payment_params
    params.require(:accounting_payment).permit(
      :payment_date, :unit_id, :accounting_invoice_id, :user_id, :vendor_id,
      :payment_type, :payment_mode, :amount, :reference_number, :notes
    )
  end

  # Auto-create income entry when payment is received against an invoice
  def create_income_entry_from_payment(payment)
    return unless payment.payment_type == 'received'
    
    # Get invoice details if linked
    invoice = payment.accounting_invoice
    invoice_number = invoice&.invoice_number || "PAY-#{payment.id}"
    source_type = invoice&.invoice_type || 'Payment'
    
    income_entry = IncomeEntry.new(
      site_id: payment.site_id,
      unit_id: payment.unit_id,
      source_type: source_type,
      source_id: invoice&.id,
      amount: payment.amount,
      invoice_number: invoice_number,
      received_date: payment.payment_date,
      payment_mode: payment.payment_mode,
      reference_number: payment.reference_number,
      user_id: payment.created_by_id,
      status: 'received',
      income_month: invoice&.income_month,
      income_year: invoice&.income_year,
      notes: "Auto-created from payment ##{payment.id}"
    )
    
    if income_entry.save
      Rails.logger.info("Income entry auto-created for payment #{payment.id}")
    else
      Rails.logger.error("Failed to create income entry: #{income_entry.errors.full_messages.join(', ')}")
    end
  end
end
