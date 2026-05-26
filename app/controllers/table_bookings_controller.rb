class TableBookingsController < ApplicationController
  include UserExt
  before_action :set_table_booking, only: %i[ show edit update destroy ]
  before_action :set_user

  def index
    @table_bookings = TableBooking.all.order("created_at DESC")
    @table_bookings = @table_bookings.for_date(params[:ondate]) if params[:ondate].present?
    @table_bookings = @table_bookings.by_status(params[:status]) if params[:status].present?
    @table_bookings = @table_bookings.where(restaurant_id: params[:restaurant_id]) if params[:restaurant_id].present?
    unless @user.fb_admin? || params[:restaurant_id].present?
      restaurant_ids = FoodAndBeverage.where(created_by_id: @user.id).pluck(:id)
      @table_bookings = @table_bookings.where(restaurant_id: restaurant_ids)
    end
    @table_bookings = @table_bookings.ransack(params[:q]).result
  end

  def show
  end

  def new
    @table_booking = TableBooking.new
    if params[:restaurant_id].present?
      @table_booking.restaurant_id = params[:restaurant_id]
      @restaurant = FoodAndBeverage.find_by(id: params[:restaurant_id])
    end
  end

  def edit
    @restaurant = @table_booking.food_and_beverage
  end

  def create
    @table_booking = TableBooking.new(table_booking_params)
    @table_booking.created_by_id = @user.id

    respond_to do |format|
      if @table_booking.save
        format.html { redirect_to @table_booking, notice: "Table booking was successfully created." }
        format.json { render :show, status: :created, location: @table_booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @table_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @table_booking.update(table_booking_params)
        format.html { redirect_to @table_booking, notice: "Table booking was successfully updated." }
        format.json { render :show, status: :ok, location: @table_booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @table_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @table_booking.destroy
    respond_to do |format|
      format.html { redirect_to table_bookings_url, notice: "Table booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def available_tables
    restaurant = FoodAndBeverage.find_by(id: params[:restaurant_id])
    return render json: { error: "Restaurant not found" }, status: :not_found unless restaurant

    date = params[:ondate].presence || Date.today
    time = params[:ontime].presence
    persons = params[:no_of_person].to_i

    all_tables = restaurant.restaurant_tables.includes(:restaurant_floor)

    booked_table_ids = TableBooking.where(restaurant_id: restaurant.id, ondate: date)
                                   .where.not(status: ["cancelled", "completed"])
                                   .where.not(id: params[:exclude_booking_id])
                                   .pluck(:restaurant_table_id)
                                   .compact

    occupied_table_numbers = RestaurantOrder.where(restaurant_id: restaurant.id, ondate: date)
                                            .where(status: ["Running", "Billed"])
                                            .where.not(table_number: nil)
                                            .pluck(:table_number)
                                            .map(&:to_s)

    available = all_tables.reject do |t|
      booked_table_ids.include?(t.id) || occupied_table_numbers.include?(t.name.to_s)
    end

    if persons > 0
      available = available.select { |t| t.capacity >= persons }
    end

    render json: available.map { |t|
      {
        id: t.id,
        name: t.name,
        capacity: t.capacity,
        floor_name: t.restaurant_floor&.name || "General"
      }
    }
  end

  private

  def set_table_booking
    @table_booking = TableBooking.find(params[:id])
  end

  def table_booking_params
    params.require(:table_booking).permit(
      :restaurant_id, :ondate, :ontime, :user_id, :no_of_person, :status,
      :created_by_id, :restaurant_table_id, :contact_number, :customer_name, :notes
    )
  end
end
