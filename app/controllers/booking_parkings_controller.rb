class BookingParkingsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_booking_parking, only: %i[ show edit update destroy ]

  # GET /booking_parkings or /booking_parkings.json
def index
  @q = BookingParking
        .joins(parking_configuration: [:building, :floor])
        .includes(
          :user,
          :created_by,
          :parking_slot,
          parking_configuration: [:building, :floor]
        )
        .where(site_id: @user.current_site_id)
        .order(created_at: :desc)
        .ransack(params[:q])

  @booking_parkings = @q.result(distinct: true).page(params[:page]).per_page(params[:per_page] || 100)

  # Vacant counts
  @two_wheeler_vacant_count = ParkingConfiguration
    .left_outer_joins(:booking_parkings)
    .where(vehicle_type: '2-wheeler', booking_parkings: { id: nil })
    .count

  @four_wheeler_vacant_count = ParkingConfiguration
    .left_outer_joins(:booking_parkings)
    .where(vehicle_type: '4-wheeler', booking_parkings: { id: nil })
    .count

  @total_allotted_slots = BookingParking
    .where(site_id: @user.current_site_id)
    .count

  @total_vacant_slots = ParkingConfiguration
    .where(site_id: @user.current_site_id, is_reserved: false)
    .left_outer_joins(:booking_parkings)
    .where(booking_parkings: { id: nil })
    .count
end


  # GET /booking_parkings/1 or /booking_parkings/1.json
  def show
  end

  # GET /booking_parkings/new
  def new
    @booking_parking = BookingParking.new
  end

  # GET /booking_parkings/1/edit
  def edit
  end

  # POST /booking_parkings or /booking_parkings.json
  def create
    @booking_parking = BookingParking.new(booking_parking_params)
    @booking_parking.site_id = @user.current_site_id

    respond_to do |format|
      if @booking_parking.save
        format.html { redirect_to @booking_parking, notice: "Booking parking was successfully created." }
        format.json { render :show, status: :created, location: @booking_parking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking_parking.errors, status: :unprocessable_entity }
      end
    end
  end


  def available_parking_configurations
    slot_id = params[:slot_id]
    date = params[:date]

    # Find bookings for the given slot and date
    bookings_for_date_and_slot = BookingParking.where(slot_id: slot_id, booking_date: date)

    if bookings_for_date_and_slot.exists?
      # Exclude parking configurations associated with existing bookings
      excluded_configurations = bookings_for_date_and_slot.pluck(:parking_id).uniq
      available_configurations = ParkingConfiguration.where.not(id: excluded_configurations)
    else
      # If no bookings exist, return all configurations
      available_configurations = ParkingConfiguration.all
    end

    render json: { data: available_configurations }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  # PATCH/PUT /booking_parkings/1 or /booking_parkings/1.json
  def update
    respond_to do |format|
      if @booking_parking.update(booking_parking_params)
        format.html { redirect_to @booking_parking, notice: "Booking parking was successfully updated." }
        format.json { render :show, status: :ok, location: @booking_parking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking_parking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /booking_parkings/1 or /booking_parkings/1.json
  def destroy
    @booking_parking.destroy
    respond_to do |format|
      format.html { redirect_to booking_parkings_url, notice: "Booking parking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking_parking
      @booking_parking = BookingParking.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def booking_parking_params
      params.require(:booking_parking).permit(:parking_id, :booking_date, :booking_start_time, :booking_end_time, :user_id, :site_id, :status, :slot_id,:created_by_id)
    end
end
