class SeatBookingsController < ApplicationController
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_seat_booking, only: %i[ show edit update destroy ]

  # GET /seat_bookings or /seat_bookings.json
  def index
    @q = SeatBooking.ransack(params[:q])
    base_scope = @q.result.where(site_id: @user.current_site_id).order(created_at: :desc)
    @seat_bookings = base_scope.page(params[:page]).per(params[:per_page] || 100)
  end

  # GET /seat_bookings/1 or /seat_bookings/1.json
  def show
  end

  # GET /seat_bookings/new
  def new
    @seat_booking = SeatBooking.new
  end

  # GET /seat_bookings/1/edit
  def edit
  end

  # POST /seat_bookings or /seat_bookings.json
  def create
    @seat_booking = SeatBooking.new(seat_booking_params)

    respond_to do |format|
      if @seat_booking.save
        format.html { redirect_to @seat_booking, notice: "Seat booking was successfully created." }
        format.json { render :show, status: :created, location: @seat_booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @seat_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seat_bookings/1 or /seat_bookings/1.json
  def update
    respond_to do |format|
      if @seat_booking.update(seat_booking_params)
        format.html { redirect_to @seat_booking, notice: "Seat booking was successfully updated." }
        format.json { render :show, status: :ok, location: @seat_booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @seat_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seat_bookings/1 or /seat_bookings/1.json
  def destroy
    @seat_booking.destroy
    respond_to do |format|
      format.html { redirect_to seat_bookings_url, notice: "Seat booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_seat_booking
    @seat_booking = SeatBooking.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def seat_booking_params
    params.require(:seat_booking).permit(:book_type, :user_id, :booking_date, :building_id, :floor_id, :booking_status, :site_id, :created_by_id)
  end
end
