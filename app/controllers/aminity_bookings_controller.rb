class AminityBookingsController < ApplicationController
      include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_aminity_booking, only: %i[ show edit update destroy ]

  # GET /aminity_bookings or /aminity_bookings.json
  def index
    @aminity_bookings = AminityBooking.where(created_by_id: @user.id)
  end

  # GET /aminity_bookings/1 or /aminity_bookings/1.json
  def show
  end

  # GET /aminity_bookings/new
  def new
    @aminity_booking = AminityBooking.new
  end

  # GET /aminity_bookings/1/edit
  def edit
  end

  # POST /aminity_bookings or /aminity_bookings.json
  def create
    @aminity_booking = AminityBooking.new(aminity_booking_params)

    respond_to do |format|
      if @aminity_booking.save
        format.html { redirect_to @aminity_booking, notice: "Aminity booking was successfully created." }
        format.json { render :show, status: :created, location: @aminity_booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @aminity_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aminity_bookings/1 or /aminity_bookings/1.json
  def update
    respond_to do |format|
      if @aminity_booking.update(aminity_booking_params)
        format.html { redirect_to @aminity_booking, notice: "Aminity booking was successfully updated." }
        format.json { render :show, status: :ok, location: @aminity_booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @aminity_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aminity_bookings/1 or /aminity_bookings/1.json
  def destroy
    @aminity_booking.destroy
    respond_to do |format|
      format.html { redirect_to aminity_bookings_url, notice: "Aminity booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aminity_booking
      @aminity_booking = AminityBooking.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def aminity_booking_params
      params.require(:aminity_booking).permit(:date, :aminity_id, :comment, :cancellation_policy, :terms_and_conditions, :payment_method, :user_id, :status, :created_by_id)
    end
end
