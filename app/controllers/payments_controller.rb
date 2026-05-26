class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy ]

  # GET /payments or /payments.json
  def index
    @payments = Payment.all
  end

  # GET /payments/1 or /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments or /payments.json
def create
  @payment = Payment.new(payment_params)

  respond_to do |format|
    if @payment.save
      if params[:payment][:resource_id].present?
        cam_bill = CamBill.find_by(id: params[:payment][:resource_id])

        if cam_bill
          cam_bill.reload  # Ensure fresh data from DB

          # Calculate the correct total amount
          total_value_sum = cam_bill.cam_bill_charges.sum(&:total).to_f
          total_due = total_value_sum + cam_bill.try(:due_amount).to_f + cam_bill.try(:due_amount_interst).to_f

          # Sum of all previous payments
          total_paid = Payment.where(resource_type: 'CamBill', resource_id: cam_bill.id).sum(:total_amount).to_f

          Rails.logger.info "DEBUG: CamBill ID: #{cam_bill.id}, Total Bill: #{total_due}, Total Paid: #{total_paid}"

          # Update payment status based on the comparison
          if total_paid >= total_due
            cam_bill.update(payment_status: "Paid")
          elsif total_paid > 0 && total_paid < total_due
            cam_bill.update(payment_status: "Partially Paid")
          end
        end
      end 

      # Handle image attachment if present
      if params[:image_url].present?
        Attachfile.create(image: params[:image_url], relation: "CamPayment", relation_id: @payment.id, active: 1)
      end

      format.html { redirect_to @payment, notice: "Payment was successfully created." }
      format.json { render :show, status: :created, location: @payment }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @payment.errors, status: :unprocessable_entity }
    end
  end
end




  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, notice: "Payment was successfully updated." }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url, notice: "Payment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:resource_id, :resource_type, :total_amount, :paid_amount, :user_id, :payment_method, :transaction_id, :paymen_date , :image, :notes)
    end
end
