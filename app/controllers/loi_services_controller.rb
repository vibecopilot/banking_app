class LoiServicesController < ApplicationController
  before_action :set_loi_service, only: %i[ show edit update destroy ]

  # GET /loi_services or /loi_services.json
  def index
    @loi_services = LoiService.all
  end

  # GET /loi_services/1 or /loi_services/1.json
  def show
  end

  # GET /loi_services/new
  def new
    @loi_service = LoiService.new
  end

  # GET /loi_services/1/edit
  def edit
  end

  # POST /loi_services or /loi_services.json
  def create
    @loi_service = LoiService.new(loi_service_params)

    respond_to do |format|
      if @loi_service.save
        format.html { redirect_to @loi_service, notice: "Loi service was successfully created." }
        format.json { render :show, status: :created, location: @loi_service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @loi_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loi_services/1 or /loi_services/1.json
  def update
    respond_to do |format|
      if @loi_service.update(loi_service_params)
        format.html { redirect_to @loi_service, notice: "Loi service was successfully updated." }
        format.json { render :show, status: :ok, location: @loi_service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @loi_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loi_services/1 or /loi_services/1.json
  def destroy
    @loi_service.destroy
    respond_to do |format|
      format.html { redirect_to loi_services_url, notice: "Loi service was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_loi_service
      @loi_service = LoiService.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def loi_service_params
      params.require(:loi_service).permit(:service_detail_id, :product_description, :quantity, :rate, :uom, :expected_date, :amount, :total_amount, :service_order_id, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt)
    end
end
