class ServiceOrdersController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_service_order, only: %i[ show edit update destroy ]

  # GET /service_orders or /service_orders.json
  def index
    @service_orders = ServiceOrder.all
  end

  # GET /service_orders/1 or /service_orders/1.json
  def show
  end

  # GET /service_orders/new
  def new
    @service_order = ServiceOrder.new
  end

  # GET /service_orders/1/edit
  def edit
  end

  # POST /service_orders or /service_orders.json
  def create
    @service_order = ServiceOrder.new(service_order_params)

    respond_to do |format|
      if @service_order.save
        if params[:service_order][:loi_service].present?
          params[:service_order][:loi_service].each do |service|
            @loi_service = LoiService.new(service.permit(:service_detail_id, :product_description, :quantity, :rate, :uom, :expected_date, :amount, :total_amount, :service_order_id, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt))
            @loi_service.service_order_id = @service_order.id
            @loi_service.save
          end
        end
        if params[:attachfiles].present? 
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "ServiceOrderDocument", relation_id: @service_order.id, active: 1)
          end
        end         
        format.html { redirect_to @service_order, notice: "Service order was successfully created." }
        format.json { render :show, status: :created, location: @service_order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @service_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_orders/1 or /service_orders/1.json
  def update
    respond_to do |format|
      if @service_order.update(service_order_params)
        format.html { redirect_to @service_order, notice: "Service order was successfully updated." }
        format.json { render :show, status: :ok, location: @service_order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @service_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_orders/1 or /service_orders/1.json
  def destroy
    @service_order.destroy
    respond_to do |format|
      format.html { redirect_to service_orders_url, notice: "Service order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_order
      @service_order = ServiceOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def service_order_params
      params.require(:service_order).permit(:pr_no, :service_order_date, :billing_address_id, :retention, :tds, :qc, :payment_tenure, :advance_amount, :related_to, :site_id, :vendor_id, :created_by_id, :reference, :active, :approved_status, :total_amount, :kind_attention, :subject, :description, :terms_and_conditions)
    end
end

