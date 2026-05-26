class MeetingRoomBookingsController < ApplicationController
  before_action :set_meeting_room_booking, only: %i[ show edit update destroy ]

  # GET /meeting_room_bookings or /meeting_room_bookings.json
  def index
    @meeting_room_bookings = MeetingRoomBooking.all
  end

  # GET /meeting_room_bookings/1 or /meeting_room_bookings/1.json
  def show
  end

  # GET /meeting_room_bookings/new
  def new
    @meeting_room_booking = MeetingRoomBooking.new
  end

  # GET /meeting_room_bookings/1/edit
  def edit
  end

  # POST /meeting_room_bookings or /meeting_room_bookings.json
  def create
    @meeting_room_booking = MeetingRoomBooking.new(meeting_room_booking_params)

    respond_to do |format|
      if @meeting_room_booking.save
        format.html { redirect_to @meeting_room_booking, notice: "Meeting room booking was successfully created." }
        format.json { render :show, status: :created, location: @meeting_room_booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meeting_room_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meeting_room_bookings/1 or /meeting_room_bookings/1.json
  def update
    respond_to do |format|
      if @meeting_room_booking.update(meeting_room_booking_params)
        format.html { redirect_to @meeting_room_booking, notice: "Meeting room booking was successfully updated." }
        format.json { render :show, status: :ok, location: @meeting_room_booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @meeting_room_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meeting_room_bookings/1 or /meeting_room_bookings/1.json
  def destroy
    @meeting_room_booking.destroy
    respond_to do |format|
      format.html { redirect_to meeting_room_bookings_url, notice: "Meeting room booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meeting_room_booking
      @meeting_room_booking = MeetingRoomBooking.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def meeting_room_booking_params
      params.require(:meeting_room_booking).permit(:book_type, :user_id, :booking_date, :facility_type, :payment_mode, :upi, :comment, :booking_status, :created_by_id)
    end
end
