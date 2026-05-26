class PurchaseOrdersController < ApplicationController
  include UserExt
  before_action :api_user
  before_action :set_purchase_order, only: %i[ show edit update destroy ]

  def index
    @purchase_orders = PurchaseOrder.where(site_id: @user.current_site_id).order(created_at: :DESC)
    @purchase_orders = @purchase_orders.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?
    @purchase_orders = @purchase_orders.where(status: params[:status]) if params[:status].present?
    @purchase_orders = @purchase_orders.ransack(params[:q]).result
  end

  def show
  end

  def new
    @purchase_order = PurchaseOrder.new
    @purchase_order.purchase_order_items.build
  end

  def edit
  end

  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @purchase_order.created_by_id = @user.id
    @purchase_order.site_id = @user.current_site_id

    respond_to do |format|
      if @purchase_order.save
        format.json { render :show, status: :created, location: @purchase_order }
      else
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @purchase_order.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.includes(:purchase_order_items).find(params[:id])
  end

  def purchase_order_params
    params.require(:purchase_order).permit(:supplier_id, :order_date, :status, :notes, :total_amount,
      purchase_order_items_attributes: [:id, :ingredient_id, :quantity, :unit_price, :total_price, :_destroy])
  end
end
