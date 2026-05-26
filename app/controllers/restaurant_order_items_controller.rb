class RestaurantOrderItemsController < ApplicationController
  before_action :set_restaurant_order_item, only: %i[ show edit update destroy ]

  # GET /restaurant_order_items or /restaurant_order_items.json
  def index
    @restaurant_order_items = RestaurantOrderItem.all
  end

  # GET /restaurant_order_items/1 or /restaurant_order_items/1.json
  def show
  end

  # GET /restaurant_order_items/new
  def new
    @restaurant_order_item = RestaurantOrderItem.new
  end

  # GET /restaurant_order_items/1/edit
  def edit
  end

  # POST /restaurant_order_items or /restaurant_order_items.json
  def create
    @restaurant_order_item = RestaurantOrderItem.new(restaurant_order_item_params)

    respond_to do |format|
      if @restaurant_order_item.save
        format.html { redirect_to @restaurant_order_item, notice: "Restaurant order item was successfully created." }
        format.json { render :show, status: :created, location: @restaurant_order_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @restaurant_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /restaurant_order_items/1 or /restaurant_order_items/1.json
  def update
    respond_to do |format|
      if @restaurant_order_item.update(restaurant_order_item_params)
        format.html { redirect_to @restaurant_order_item, notice: "Restaurant order item was successfully updated." }
        format.json { render :show, status: :ok, location: @restaurant_order_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @restaurant_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /restaurant_order_items/1 or /restaurant_order_items/1.json
  def destroy
    @restaurant_order_item.destroy
    respond_to do |format|
      format.html { redirect_to restaurant_order_items_url, notice: "Restaurant order item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_restaurant_order_item
      @restaurant_order_item = RestaurantOrderItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def restaurant_order_item_params
      params.require(:restaurant_order_item).permit(:order_id, :restaurant_menu_id, :quantity, :amount, :rate)
    end
end
