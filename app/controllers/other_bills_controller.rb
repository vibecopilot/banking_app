class OtherBillsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user 
  before_action :set_user
  before_action :set_other_bill, only: %i[ show edit update destroy ]

  # GET /other_bills or /other_bills.json
  def index
    @other_bills = OtherBill.all.order(created_at: :DESC)
  end

  # GET /other_bills/1 or /other_bills/1.json
  def show
  end

  # GET /other_bills/new
  def new
    @other_bill = OtherBill.new
  end

  # GET /other_bills/1/edit
  def edit
  end

  # POST /other_bills or /other_bills.json
  def create
    @other_bill = OtherBill.new(other_bill_params)
    @other_bill.created_by_id = @user.id

    respond_to do |format|
      if @other_bill.save
        if params[:attachfiles].present? 
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "OtherBillDocument", relation_id: @other_bill.id, active: 1)
          end
        end
        format.html { redirect_to @other_bill, notice: "Other bill was successfully created." }
        format.json { render :show, status: :created, location: @other_bill }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @other_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /other_bills/1 or /other_bills/1.json
  def update
    respond_to do |format|
      if @other_bill.update(other_bill_params)
        format.html { redirect_to @other_bill, notice: "Other bill was successfully updated." }
        format.json { render :show, status: :ok, location: @other_bill }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @other_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /other_bills/1 or /other_bills/1.json
  def destroy
    @other_bill.destroy
    respond_to do |format|
      format.html { redirect_to other_bills_url, notice: "Other bill was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_other_bill
      @other_bill = OtherBill.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def other_bill_params
      params.require(:other_bill).permit(:pan_no, :gst_no, :vendor_id, :bill_date, :invoice_number, :related_to, :tds_percentage, :retention_percentage, :deduction_remarks, :deduction_amount, :additional_expenses, :payment_tenure, :cgst_rate, :cgst_amount, :sgst_rate, :sgst_amount, :igst_rate, :igst_amount, :tcs_rate, :tcs_amount, :tax_amount, :total_amount, :description, :created_by_id,:amount,:base_amount,:tds_rate,:tds_amount)
    end
end