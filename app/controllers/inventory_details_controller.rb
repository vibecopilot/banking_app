class InventoryDetailsController < ApplicationController
  before_action :set_inventory_detail, only: %i[ show edit update destroy ]

  # GET /inventory_details or /inventory_details.json
  def index
    @inventory_details = InventoryDetail.all
  end

  # GET /inventory_details/1 or /inventory_details/1.json
  def show
  end

  # GET /inventory_details/new
  def new
    @inventory_detail = InventoryDetail.new
  end

  # GET /inventory_details/1/edit
  def edit
  end

  # POST /inventory_details or /inventory_details.json
  def create
    @inventory_detail = InventoryDetail.new(inventory_detail_params)
    respond_to do |format|
      if @inventory_detail.save
        format.html { redirect_to @inventory_detail, notice: "Inventory detail was successfully created." }
        format.json { render :show, status: :created, location: @inventory_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @inventory_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventory_details/1 or /inventory_details/1.json
  def update
    respond_to do |format|
      if @inventory_detail.update(inventory_detail_params)
        format.html { redirect_to @inventory_detail, notice: "Inventory detail was successfully updated." }
        format.json { render :show, status: :ok, location: @inventory_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @inventory_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_details/1 or /inventory_details/1.json
  def destroy
    @inventory_detail.destroy
    respond_to do |format|
      format.html { redirect_to inventory_details_url, notice: "Inventory detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_detail
      @inventory_detail = InventoryDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def inventory_detail_params
      params.require(:inventory_detail).permit(:item_id, :expected_quantity, :received_quantity, :approved_quantity, :rejected_quantity, :rate, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :inventory_amount, :total_amount, :grn_id)
    end
end
