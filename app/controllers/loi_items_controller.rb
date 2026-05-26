class LoiItemsController < ApplicationController
  before_action :set_loi_item, only: %i[ show edit update destroy ]

  # GET /loi_items or /loi_items.json
  def index
    @loi_items = LoiItem.all
  end

  # GET /loi_items/1 or /loi_items/1.json
  def show
  end

  # GET /loi_items/new
  def new
    @loi_item = LoiItem.new
  end

  # GET /loi_items/1/edit
  def edit
  end

  # POST /loi_items or /loi_items.json
  def create
    @loi_item = LoiItem.new(loi_item_params)

    respond_to do |format|
      if @loi_item.save
        format.html { redirect_to @loi_item, notice: "Loi item was successfully created." }
        format.json { render :show, status: :created, location: @loi_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @loi_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loi_items/1 or /loi_items/1.json
  def update
    respond_to do |format|
      if @loi_item.update(loi_item_params)
        format.html { redirect_to @loi_item, notice: "Loi item was successfully updated." }
        format.json { render :show, status: :ok, location: @loi_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @loi_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loi_items/1 or /loi_items/1.json
  def destroy
    @loi_item.destroy
    respond_to do |format|
      format.html { redirect_to loi_items_url, notice: "Loi item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_loi_item
      @loi_item = LoiItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def loi_item_params
      params.require(:loi_item).permit(:loi_detail_id, :item_id, :sac_code, :quantity, :standard_unit_id, :expected_date, :rate, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :amount, :total_amount)
    end
end
