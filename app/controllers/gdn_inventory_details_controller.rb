class GdnInventoryDetailsController < ApplicationController
  before_action :set_gdn_inventory_detail, only: %i[ show edit update destroy ]

  # GET /gdn_inventory_details or /gdn_inventory_details.json
  def index
    @gdn_inventory_details = GdnInventoryDetail.all
  end

  # GET /gdn_inventory_details/1 or /gdn_inventory_details/1.json
  def show
  end

  # GET /gdn_inventory_details/new
  def new
    @gdn_inventory_detail = GdnInventoryDetail.new
  end

  # GET /gdn_inventory_details/1/edit
  def edit
  end

  # POST /gdn_inventory_details or /gdn_inventory_details.json
  def create
    @gdn_inventory_detail = GdnInventoryDetail.new(gdn_inventory_detail_params)

    respond_to do |format|
      if @gdn_inventory_detail.save
        format.html { redirect_to @gdn_inventory_detail, notice: "Gdn inventory detail was successfully created." }
        format.json { render :show, status: :created, location: @gdn_inventory_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gdn_inventory_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gdn_inventory_details/1 or /gdn_inventory_details/1.json
  def update
    respond_to do |format|
      if @gdn_inventory_detail.update(gdn_inventory_detail_params)
        format.html { redirect_to @gdn_inventory_detail, notice: "Gdn inventory detail was successfully updated." }
        format.json { render :show, status: :ok, location: @gdn_inventory_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gdn_inventory_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gdn_inventory_details/1 or /gdn_inventory_details/1.json
  def destroy
    @gdn_inventory_detail.destroy
    respond_to do |format|
      format.html { redirect_to gdn_inventory_details_url, notice: "Gdn inventory detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gdn_inventory_detail
      @gdn_inventory_detail = GdnInventoryDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def gdn_inventory_detail_params
      params.require(:gdn_inventory_detail).permit(:inventory, :current_stock, :quantity, :comments, :gdn_id)
    end
end
