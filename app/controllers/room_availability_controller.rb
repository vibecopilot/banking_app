class RoomAvailabilityController < ApplicationController
  before_action :authenticate_user!
  before_action :set_site
  before_action :set_room
  before_action :set_room_availability, only: [:show, :update, :destroy]
  before_action :check_admin_access

  # GET /rooms/1/room_availability
  def index
    start_date = Date.parse(params[:start_date]) rescue Date.current
    end_date = Date.parse(params[:end_date]) rescue (Date.current + 30.days)

    @room_availability = @room.room_availability.for_date_range(start_date, end_date)
    
    respond_to do |format|
      format.html
      format.json { render json: availability_records_json(@room_availability, start_date, end_date) }
    end
  end

  # GET /rooms/1/room_availability/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: availability_record_json(@room_availability) }
    end
  end

  # POST /rooms/1/room_availability
  def create
    @room_availability = @room.room_availability.build(room_availability_params)

    if @room_availability.save
      respond_to do |format|
        format.html { redirect_to [@site, @room, :room_availability], notice: 'Room availability was successfully created.' }
        format.json { render json: availability_record_json(@room_availability), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @room_availability.errors }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1/room_availability/1
  def update
    if @room_availability.update(room_availability_params)
      respond_to do |format|
        format.html { redirect_to [@site, @room, @room_availability], notice: 'Room availability was successfully updated.' }
        format.json { render json: availability_record_json(@room_availability) }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { errors: @room_availability.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1/room_availability/1
  def destroy
    @room_availability.destroy
    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_availability], notice: 'Room availability was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # POST /rooms/1/room_availability/block_dates
  def block_dates
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    reason = params[:reason] || 'Blocked by admin'

    RoomAvailability.block_dates(@room, start_date, end_date, reason)

    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_availability], notice: 'Dates blocked successfully.' }
      format.json { render json: { message: "Dates from #{start_date} to #{end_date} blocked successfully" } }
    end
  rescue ArgumentError => e
    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_availability], alert: 'Invalid date format.' }
      format.json { render json: { error: 'Invalid date format' }, status: :unprocessable_entity }
    end
  end

  # POST /rooms/1/room_availability/unblock_dates
  def unblock_dates
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    RoomAvailability.unblock_dates(@room, start_date, end_date)

    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_availability], notice: 'Dates unblocked successfully.' }
      format.json { render json: { message: "Dates from #{start_date} to #{end_date} unblocked successfully" } }
    end
  rescue ArgumentError => e
    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_availability], alert: 'Invalid date format.' }
      format.json { render json: { error: 'Invalid date format' }, status: :unprocessable_entity }
    end
  end

  # POST /rooms/1/room_availability/set_availability
  def set_availability
    date = Date.parse(params[:date])
    available = params[:available] == 'true'
    reason = params[:reason]

    RoomAvailability.set_availability(@room, date, available, reason)

    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_availability], notice: 'Availability updated successfully.' }
      format.json { render json: { message: "Availability for #{date} updated successfully" } }
    end
  rescue ArgumentError => e
    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_availability], alert: 'Invalid date format.' }
      format.json { render json: { error: 'Invalid date format' }, status: :unprocessable_entity }
    end
  end

  # GET /rooms/1/room_availability/calendar
  def calendar
    start_date = Date.parse(params[:start_date]) rescue Date.current.beginning_of_month
    end_date = Date.parse(params[:end_date]) rescue Date.current.end_of_month

    calendar_data = []
    (start_date..end_date).each do |date|
      availability = @room.room_availability.find_by(date: date)
      is_available = @room.available_on_dates?(date, date + 1.day)
      
      calendar_data << {
        date: date,
        available: is_available,
        has_restriction: availability.present?,
        reason: availability&.display_reason,
        bookings: @room.room_bookings.by_date_range(date, date).map do |booking|
          {
            id: booking.id,
            reference: booking.booking_reference,
            guest_name: booking.guest_name,
            status: booking.status
          }
        end
      }
    end

    respond_to do |format|
      format.json { render json: { calendar: calendar_data } }
    end
  end

  private

  def set_site
    @site = Site.find(params[:site_id]) if params[:site_id]
    @site ||= current_user.site
  end

  def set_room
    @room = @site.rooms.find(params[:room_id])
  end

  def set_room_availability
    @room_availability = @room.room_availability.find(params[:id])
  end

  def check_admin_access
    unless current_user.admin? || current_user.manager?
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Access denied.' }
        format.json { render json: { error: 'Access denied' }, status: :forbidden }
      end
    end
  end

  def room_availability_params
    params.require(:room_availability).permit(:date, :available, :reason)
  end

  def availability_records_json(availability_records, start_date, end_date)
    {
      availability_records: availability_records.map { |availability| availability_record_json(availability) },
      date_range: {
        start_date: start_date,
        end_date: end_date
      }
    }
  end

  def availability_record_json(availability)
    {
      id: availability.id,
      room_id: availability.room_id,
      date: availability.date,
      available: availability.available,
      reason: availability.reason,
      display_reason: availability.display_reason,
      blocked: availability.blocked?,
      created_at: availability.created_at,
      updated_at: availability.updated_at
    }
  end
end
