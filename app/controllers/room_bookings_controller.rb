class RoomBookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_site
  before_action :set_room_booking, only: [:show, :edit, :update, :destroy, :check_in, :check_out, :cancel]
  before_action :check_booking_access, only: [:show, :edit, :update, :destroy, :cancel]
  before_action :check_admin_access, only: [:check_in, :check_out]

  # GET /room_bookings
  def index
    @room_bookings = @site.room_bookings.includes(:room, :user)

    # Admin can see all bookings, users can only see their own
    unless current_user.admin? || current_user.manager?
      @room_bookings = @room_bookings.where(user: current_user)
    end

    # Filter by status
    if params[:status].present?
      @room_bookings = @room_bookings.where(status: params[:status])
    end

    # Filter by date range
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]) rescue nil
      end_date = Date.parse(params[:end_date]) rescue nil
      if start_date && end_date
        @room_bookings = @room_bookings.by_date_range(start_date, end_date)
      end
    end

    # Filter by room
    if params[:room_id].present?
      @room_bookings = @room_bookings.where(room_id: params[:room_id])
    end

    @room_bookings = @room_bookings.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: bookings_json(@room_bookings) }
    end
  end

  # GET /room_bookings/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: booking_json(@room_booking) }
    end
  end

  # GET /room_bookings/new
  def new
    @room_booking = RoomBooking.new
    @room = @site.rooms.find(params[:room_id]) if params[:room_id]
    
    # Pre-fill dates if provided
    if params[:check_in].present? && params[:check_out].present?
      @room_booking.check_in_date = Date.parse(params[:check_in]) rescue nil
      @room_booking.check_out_date = Date.parse(params[:check_out]) rescue nil
    end

    # Pre-fill guest count if provided
    @room_booking.number_of_adults = params[:adults].to_i if params[:adults].present?
    @room_booking.number_of_children = params[:children].to_i if params[:children].present?
  end

  # GET /room_bookings/1/edit
  def edit
  end

  # POST /room_bookings
  def create
    @room_booking = @site.room_bookings.build(room_booking_params)
    @room_booking.user = current_user

    if @room_booking.save
      # Send confirmation email/notification here
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], notice: 'Room booking was successfully created.' }
        format.json { render json: booking_json(@room_booking), status: :created }
      end
    else
      @room = @room_booking.room
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @room_booking.errors }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /room_bookings/1
  def update
    # Only allow updates if booking is still pending or confirmed
    unless @room_booking.pending? || @room_booking.confirmed?
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], alert: 'Cannot modify booking in current status.' }
        format.json { render json: { error: 'Cannot modify booking in current status' }, status: :unprocessable_entity }
      end
      return
    end

    if @room_booking.update(room_booking_params)
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], notice: 'Room booking was successfully updated.' }
        format.json { render json: booking_json(@room_booking) }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { errors: @room_booking.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /room_bookings/1
  def destroy
    unless @room_booking.can_cancel?
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], alert: 'Cannot cancel booking in current status.' }
        format.json { render json: { error: 'Cannot cancel booking' }, status: :unprocessable_entity }
      end
      return
    end

    @room_booking.cancel!('Cancelled by user')
    
    respond_to do |format|
      format.html { redirect_to [@site, :room_bookings], notice: 'Booking was successfully cancelled.' }
      format.json { render json: { message: 'Booking cancelled successfully' } }
    end
  end

  # POST /room_bookings/1/check_in
  def check_in
    if @room_booking.check_in!
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], notice: 'Guest checked in successfully.' }
        format.json { render json: booking_json(@room_booking) }
      end
    else
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], alert: 'Cannot check in at this time.' }
        format.json { render json: { error: 'Cannot check in' }, status: :unprocessable_entity }
      end
    end
  end

  # POST /room_bookings/1/check_out
  def check_out
    if @room_booking.check_out!
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], notice: 'Guest checked out successfully.' }
        format.json { render json: booking_json(@room_booking) }
      end
    else
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], alert: 'Cannot check out at this time.' }
        format.json { render json: { error: 'Cannot check out' }, status: :unprocessable_entity }
      end
    end
  end

  # POST /room_bookings/1/cancel
  def cancel
    reason = params[:reason] || 'Cancelled by admin'
    
    if @room_booking.cancel!(reason)
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], notice: 'Booking cancelled successfully.' }
        format.json { render json: booking_json(@room_booking) }
      end
    else
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], alert: 'Cannot cancel booking.' }
        format.json { render json: { error: 'Cannot cancel booking' }, status: :unprocessable_entity }
      end
    end
  end

  # GET /room_bookings/pricing_info
  def pricing_info
    room = @site.rooms.find(params[:room_id])
    check_in = Date.parse(params[:check_in]) rescue Date.current
    check_out = Date.parse(params[:check_out]) rescue (Date.current + 1.day)

    pricing_info = {
      room_id: room.id,
      room_name: room.display_name,
      check_in_date: check_in,
      check_out_date: check_out,
      nights: (check_out - check_in).to_i,
      base_price_per_night: room.base_price_per_night,
      tax_percentage: room.tax_percentage,
      subtotal: room.total_price_for_stay(check_in, check_out),
      tax_amount: room.tax_amount_for_stay(check_in, check_out),
      total_amount: room.total_with_tax_for_stay(check_in, check_out),
      daily_breakdown: []
    }

    (check_in...check_out).each do |date|
      pricing_info[:daily_breakdown] << {
        date: date,
        price: room.price_for_date(date)
      }
    end

    respond_to do |format|
      format.json { render json: pricing_info }
    end
  end

  # POST /room_bookings/confirm
  def confirm
    @room_booking = @site.room_bookings.find(params[:id])
    
    if @room_booking.pending? && @room_booking.update(status: 'confirmed')
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], notice: 'Booking confirmed successfully.' }
        format.json { render json: booking_json(@room_booking) }
      end
    else
      respond_to do |format|
        format.html { redirect_to [@site, @room_booking], alert: 'Cannot confirm booking.' }
        format.json { render json: { error: 'Cannot confirm booking' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_site
    @site = Site.find(params[:site_id]) if params[:site_id]
    @site ||= current_user.site
  end

  def set_room_booking
    @room_booking = @site.room_bookings.find(params[:id])
  end

  def check_booking_access
    unless current_user.admin? || current_user.manager? || @room_booking.user == current_user
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Access denied.' }
        format.json { render json: { error: 'Access denied' }, status: :forbidden }
      end
    end
  end

  def check_admin_access
    unless current_user.admin? || current_user.manager?
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Access denied.' }
        format.json { render json: { error: 'Access denied' }, status: :forbidden }
      end
    end
  end

  def room_booking_params
    params.require(:room_booking).permit(
      :room_id, :check_in_date, :check_out_date, :number_of_adults, :number_of_children,
      :guest_name, :guest_email, :guest_phone, :special_requests, :payment_status
    )
  end

  def bookings_json(bookings)
    {
      bookings: bookings.map { |booking| booking_json(booking) }
    }
  end

  def booking_json(booking)
    {
      id: booking.id,
      booking_reference: booking.booking_reference,
      room: {
        id: booking.room.id,
        name: booking.room.name,
        room_number: booking.room.room_number,
        room_type: booking.room.room_type
      },
      user: {
        id: booking.user.id,
        name: booking.user.full_name,
        email: booking.user.email
      },
      check_in_date: booking.check_in_date,
      check_out_date: booking.check_out_date,
      display_dates: booking.display_dates,
      duration_nights: booking.duration_nights,
      number_of_adults: booking.number_of_adults,
      number_of_children: booking.number_of_children,
      guest_count: booking.guest_count,
      guest_name: booking.guest_name,
      guest_email: booking.guest_email,
      guest_phone: booking.guest_phone,
      special_requests: booking.special_requests,
      subtotal_amount: booking.subtotal_amount,
      tax_amount: booking.tax_amount,
      total_amount: booking.total_amount,
      status: booking.status,
      payment_status: booking.payment_status,
      actual_check_in_time: booking.actual_check_in_time,
      actual_check_out_time: booking.actual_check_out_time,
      cancellation_reason: booking.cancellation_reason,
      cancelled_at: booking.cancelled_at,
      created_at: booking.created_at,
      can_check_in: booking.can_check_in?,
      can_check_out: booking.can_check_out?,
      can_cancel: booking.can_cancel?,
      is_overdue: booking.is_overdue?
    }
  end
end
