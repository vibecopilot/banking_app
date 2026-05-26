class StatusRestaurantsController < ApplicationController
  before_action :set_status_restaurant, only: %i[ show edit update destroy ]

  # GET /status_restaurants or /status_restaurants.json
  def index
    @status_restaurants = StatusRestaurant.all
  end

  # GET /status_restaurants/1 or /status_restaurants/1.json
  def show
  end

  # GET /status_restaurants/new
  def new
    @status_restaurant = StatusRestaurant.new
  end

  # GET /status_restaurants/1/edit
  def edit
  end

  # POST /status_restaurants or /status_restaurants.json
  def create
    @status_restaurant = StatusRestaurant.new(status_restaurant_params)

    respond_to do |format|
      if @status_restaurant.save
        format.html { redirect_to @status_restaurant, notice: "Status restaurant was successfully created." }
        format.json { render :show, status: :created, location: @status_restaurant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @status_restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /status_restaurants/1 or /status_restaurants/1.json
  def update
    respond_to do |format|
      if @status_restaurant.update(status_restaurant_params)
        format.html { redirect_to @status_restaurant, notice: "Status restaurant was successfully updated." }
        format.json { render :show, status: :ok, location: @status_restaurant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @status_restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /status_restaurants/1 or /status_restaurants/1.json
  def destroy
    @status_restaurant.destroy
    respond_to do |format|
      format.html { redirect_to status_restaurants_url, notice: "Status restaurant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_status_restaurant
      @status_restaurant = StatusRestaurant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def status_restaurant_params
      params.require(:status_restaurant).permit(:status, :display_name, { fixed_state: [] }, :order, :color,:site_id)
    end
end
