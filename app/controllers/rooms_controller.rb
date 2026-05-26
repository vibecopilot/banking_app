class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_site
  before_action :set_room, only: [:show, :edit, :update, :destroy, :availability, :pricing]
  before_action :check_admin_access, except: [:index, :show, :search, :available_rooms]

  # GET /rooms
  def index
    @rooms = @site.rooms.includes(:room_pricing, :room_availability)
    
    if params[:room_type].present?
      @rooms = @rooms.where(room_type: params[:room_type])
    end
    
    if params[:status].present?
      @rooms = @rooms.where(status: params[:status])
    end
    
    if params[:floor].present?
      @rooms = @rooms.where(floor_number: params[:floor])
    end
    
    @rooms = @rooms.active if params[:active_only] == 'true'
    
    respond_to do |format|
      format.html
      format.json { render json: rooms_json(@rooms) }
    end
  end

  # GET /rooms/1
  def show
    @current_bookings = @room.room_bookings.current.includes(:user)
    @upcoming_bookings = @room.room_bookings.where(
      status: 'confirmed',
      check_in_date: Date.current..
    ).order(:check_in_date).limit(5)
    
    respond_to do |format|
      format.html
      format.json { render json: room_json(@room) }
    end
  end

  # GET /rooms/new
  def new
    @room = @site.rooms.build
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  def create
    @room = @site.rooms.build(room_params)

    if @room.save
      respond_to do |format|
        format.html { redirect_to [@site, @room], notice: 'Room was successfully created.' }
        format.json { render json: room_json(@room), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @room.errors }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  def update
    if @room.update(room_params)
      respond_to do |format|
        format.html { redirect_to [@site, @room], notice: 'Room was successfully updated.' }
        format.json { render json: room_json(@room) }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { errors: @room.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  def destroy
    if @room.room_bookings.active.any?
      respond_to do |format|
        format.html { redirect_to [@site, :rooms], alert: 'Cannot delete room with active bookings.' }
        format.json { render json: { error: 'Cannot delete room with active bookings' }, status: :unprocessable_entity }
      end
    else
      @room.destroy
      respond_to do |format|
        format.html { redirect_to [@site, :rooms], notice: 'Room was successfully deleted.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /rooms/search
  def search
    check_in = Date.parse(params[:check_in]) rescue Date.current
    check_out = Date.parse(params[:check_out]) rescue (Date.current + 1.day)
    adults = params[:adults].to_i
    children = params[:children].to_i

    @available_rooms = @site.rooms
                           .active
                           .available_for_dates(check_in, check_out)
                           .where('max_adults >= ? AND max_children >= ?', adults, children)

    if params[:room_type].present?
      @available_rooms = @available_rooms.where(room_type: params[:room_type])
    end

    if params[:max_price].present?
      max_price = params[:max_price].to_f
      @available_rooms = @available_rooms.select do |room|
        room.total_price_for_stay(check_in, check_out) <= max_price
      end
    end

    @search_params = {
      check_in: check_in,
      check_out: check_out,
      adults: adults,
      children: children,
      room_type: params[:room_type],
      max_price: params[:max_price]
    }

    respond_to do |format|
      format.html
      format.json { render json: search_results_json(@available_rooms, check_in, check_out) }
    end
  end

  # GET /rooms/available
  def available_rooms
    check_in = Date.parse(params[:check_in]) rescue Date.current
    check_out = Date.parse(params[:check_out]) rescue (Date.current + 1.day)

    @available_rooms = @site.rooms
                           .active
                           .available_for_dates(check_in, check_out)

    respond_to do |format|
      format.json { render json: available_rooms_json(@available_rooms, check_in, check_out) }
    end
  end

  # GET /rooms/1/availability
  def availability
    start_date = Date.parse(params[:start_date]) rescue Date.current
    end_date = Date.parse(params[:end_date]) rescue (Date.current + 30.days)

    availability_data = []
    (start_date..end_date).each do |date|
      availability_data << {
        date: date,
        available: @room.available_on_dates?(date, date + 1.day),
        price: @room.price_for_date(date),
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
      format.json { render json: { availability: availability_data } }
    end
  end

  # GET /rooms/1/pricing
  def pricing
    @pricing_records = @room.room_pricing.order(:start_date)
    
    respond_to do |format|
      format.html
      format.json { render json: pricing_json(@pricing_records) }
    end
  end

  private

  def set_site
    @site = Site.find(params[:site_id]) if params[:site_id]
    @site ||= current_user.site
  end

  def set_room
    @room = @site.rooms.find(params[:id])
  end

  def check_admin_access
    unless current_user.admin? || current_user.manager?
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Access denied.' }
        format.json { render json: { error: 'Access denied' }, status: :forbidden }
      end
    end
  end

  def room_params
    params.require(:room).permit(
      :name, :room_number, :room_type, :floor_number, :description,
      :base_price_per_night, :tax_percentage, :max_adults, :max_children,
      :amenities, :status, :active
    )
  end

  def rooms_json(rooms)
    {
      rooms: rooms.map { |room| room_json(room) }
    }
  end

  def room_json(room)
    {
      id: room.id,
      name: room.name,
      room_number: room.room_number,
      room_type: room.room_type,
      floor_number: room.floor_number,
      description: room.description,
      base_price_per_night: room.base_price_per_night,
      tax_percentage: room.tax_percentage,
      max_adults: room.max_adults,
      max_children: room.max_children,
      amenities: room.amenities,
      status: room.status,
      active: room.active,
      display_name: room.display_name,
      capacity: room.capacity,
      site_id: room.site_id
    }
  end

  def search_results_json(rooms, check_in, check_out)
    {
      rooms: rooms.map do |room|
        room_data = room_json(room)
        room_data.merge!({
          total_price: room.total_price_for_stay(check_in, check_out),
          tax_amount: room.tax_amount_for_stay(check_in, check_out),
          total_with_tax: room.total_with_tax_for_stay(check_in, check_out),
          nights: (check_out - check_in).to_i
        })
        room_data
      end,
      search_params: @search_params
    }
  end

  def available_rooms_json(rooms, check_in, check_out)
    {
      available_rooms: rooms.map do |room|
        {
          id: room.id,
          name: room.name,
          room_number: room.room_number,
          room_type: room.room_type,
          capacity: room.capacity,
          total_price: room.total_price_for_stay(check_in, check_out)
        }
      end
    }
  end

  def pricing_json(pricing_records)
    {
      pricing: pricing_records.map do |pricing|
        {
          id: pricing.id,
          start_date: pricing.start_date,
          end_date: pricing.end_date,
          price_per_night: pricing.price_per_night,
          pricing_type: pricing.pricing_type,
          reason: pricing.reason,
          active: pricing.active,
          display_period: pricing.display_period,
          price_difference: pricing.price_difference,
          price_difference_percentage: pricing.price_difference_percentage
        }
      end
    }
  end
end
