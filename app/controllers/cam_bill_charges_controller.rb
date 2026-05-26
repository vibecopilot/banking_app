class CamBillChargesController < ApplicationController
  before_action :set_cam_bill_charge, only: %i[ show edit update destroy ]

  # GET /cam_bill_charges or /cam_bill_charges.json
  def index
    @cam_bill_charges = CamBillCharge.all
  end

  # GET /cam_bill_charges/1 or /cam_bill_charges/1.json
  def show
  end

  # GET /cam_bill_charges/new
  def new
    @cam_bill_charge = CamBillCharge.new
  end

  # GET /cam_bill_charges/1/edit
  def edit
  end

  # POST /cam_bill_charges or /cam_bill_charges.json
  def create
    @cam_bill_charge = CamBillCharge.new(cam_bill_charge_params)

    respond_to do |format|
      if @cam_bill_charge.save
        format.html { redirect_to @cam_bill_charge, notice: "Cam bill charge was successfully created." }
        format.json { render :show, status: :created, location: @cam_bill_charge }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cam_bill_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cam_bill_charges/1 or /cam_bill_charges/1.json
  def update
    respond_to do |format|
      if @cam_bill_charge.update(cam_bill_charge_params)
        format.html { redirect_to @cam_bill_charge, notice: "Cam bill charge was successfully updated." }
        format.json { render :show, status: :ok, location: @cam_bill_charge }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cam_bill_charge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cam_bill_charges/1 or /cam_bill_charges/1.json
  def destroy
    @cam_bill_charge.destroy
    respond_to do |format|
      format.html { redirect_to cam_bill_charges_url, notice: "Cam bill charge was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cam_bill_charge
      @cam_bill_charge = CamBillCharge.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cam_bill_charge_params
      params.require(:cam_bill_charge).permit(:charge_id, :charge_amount, :sub_amount, :cgst_amount, :igst_amount, :sgst_amount, :description, :cam_bill_id)
    end
end
