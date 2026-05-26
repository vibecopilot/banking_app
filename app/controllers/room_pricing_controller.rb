class RoomPricingController < ApplicationController
  before_action :authenticate_user!
  before_action :set_site
  before_action :set_room
  before_action :set_room_pricing, only: [:show, :edit, :update, :destroy]
  before_action :check_admin_access

  # GET /rooms/1/room_pricing
  def index
    @room_pricing = @room.room_pricing.order(:start_date)
    
    respond_to do |format|
      format.html
      format.json { render json: pricing_records_json(@room_pricing) }
    end
  end

  # GET /rooms/1/room_pricing/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: pricing_record_json(@room_pricing) }
    end
  end

  # GET /rooms/1/room_pricing/new
  def new
    @room_pricing = @room.room_pricing.build
  end

  # GET /rooms/1/room_pricing/1/edit
  def edit
  end

  # POST /rooms/1/room_pricing
  def create
    @room_pricing = @room.room_pricing.build(room_pricing_params)

    if @room_pricing.save
      respond_to do |format|
        format.html { redirect_to [@site, @room, @room_pricing], notice: 'Room pricing was successfully created.' }
        format.json { render json: pricing_record_json(@room_pricing), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @room_pricing.errors }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1/room_pricing/1
  def update
    if @room_pricing.update(room_pricing_params)
      respond_to do |format|
        format.html { redirect_to [@site, @room, @room_pricing], notice: 'Room pricing was successfully updated.' }
        format.json { render json: pricing_record_json(@room_pricing) }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { errors: @room_pricing.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1/room_pricing/1
  def destroy
    @room_pricing.destroy
    respond_to do |format|
      format.html { redirect_to [@site, @room, :room_pricing], notice: 'Room pricing was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # POST /rooms/1/room_pricing/bulk_create
  def bulk_create
    pricing_data = params[:pricing_records] || []
    created_records = []
    errors = []

    pricing_data.each_with_index do |pricing_params, index|
      pricing = @room.room_pricing.build(
        start_date: pricing_params[:start_date],
        end_date: pricing_params[:end_date],
        price_per_night: pricing_params[:price_per_night],
        pricing_type: pricing_params[:pricing_type],
        reason: pricing_params[:reason],
        active: pricing_params[:active] || true
      )

      if pricing.save
        created_records << pricing
      else
        errors << { index: index, errors: pricing.errors }
      end
    end

    respond_to do |format|
      if errors.empty?
        format.json { 
          render json: { 
            message: "#{created_records.count} pricing records created successfully",
            created_records: pricing_records_json(created_records)
          }
        }
      else
        format.json { 
          render json: { 
            message: "#{created_records.count} records created, #{errors.count} failed",
            created_records: pricing_records_json(created_records),
            errors: errors
          }, status: :unprocessable_entity
        }
      end
    end
  end

  # GET /rooms/1/room_pricing/calendar
  def calendar
    start_date = Date.parse(params[:start_date]) rescue Date.current.beginning_of_month
    end_date = Date.parse(params[:end_date]) rescue Date.current.end_of_month

    calendar_data = []
    (start_date..end_date).each do |date|
      pricing = @room.room_pricing.for_date(date).active.first
      calendar_data << {
        date: date,
        price: pricing ? pricing.price_per_night : @room.base_price_per_night,
        has_special_pricing: pricing.present?,
        pricing_type: pricing&.pricing_type,
        reason: pricing&.reason
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

  def set_room_pricing
    @room_pricing = @room.room_pricing.find(params[:id])
  end

  def check_admin_access
    unless current_user.admin? || current_user.manager?
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Access denied.' }
        format.json { render json: { error: 'Access denied' }, status: :forbidden }
      end
    end
  end

  def room_pricing_params
    params.require(:room_pricing).permit(
      :start_date, :end_date, :price_per_night, :pricing_type, :reason, :active
    )
  end

  def pricing_records_json(pricing_records)
    {
      pricing_records: pricing_records.map { |pricing| pricing_record_json(pricing) }
    }
  end

  def pricing_record_json(pricing)
    {
      id: pricing.id,
      room_id: pricing.room_id,
      start_date: pricing.start_date,
      end_date: pricing.end_date,
      price_per_night: pricing.price_per_night,
      pricing_type: pricing.pricing_type,
      reason: pricing.reason,
      active: pricing.active,
      duration_days: pricing.duration_days,
      display_period: pricing.display_period,
      price_difference: pricing.price_difference,
      price_difference_percentage: pricing.price_difference_percentage,
      is_discount: pricing.is_discount?,
      is_premium: pricing.is_premium?,
      created_at: pricing.created_at,
      updated_at: pricing.updated_at
    }
  end
end
