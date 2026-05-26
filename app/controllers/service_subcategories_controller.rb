class ServiceSubcategoriesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_service_subcategory, only: [:show, :edit, :update, :destroy, :available_slots, :pricing_info]

  # GET /service_subcategories
  # GET /service_subcategories.json
  def index
    @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id)
                                               .active
                                               .includes(:service_category, :service_slots, :service_pricings)

    @service_subcategories = @service_subcategories.for_category(params[:category_id]) if params[:category_id].present?

    respond_to do |format|
      format.html
      format.json {render 'service_sub_cat', status: :ok}
    end
  end

  # GET /service_subcategories/1
  # GET /service_subcategories/1.json
  def show
    @slots = @service_subcategory.service_slots.active.ordered
    @pricings = @service_subcategory.service_pricings.active.includes(:unit_configuration)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          id: @service_subcategory.id,
          name: @service_subcategory.name,
          description: @service_subcategory.description,
          terms_and_conditions: @service_subcategory.terms_and_conditions,
          duration_minutes: @service_subcategory.duration_minutes,
          advance_booking_hours: @service_subcategory.advance_booking_hours,
          cancellation_hours: @service_subcategory.cancellation_hours,
          category: {
            id: @service_subcategory.service_category.id,
            name: @service_subcategory.service_category.name
          },
          slots: @slots.map do |slot|
            {
              id: slot.id,
              start_time: slot.start_time.strftime('%H:%M'),
              end_time: slot.end_time.strftime('%H:%M'),
              display_time: slot.display_time,
              max_bookings: slot.max_bookings
            }
          end,
          pricings: @pricings.map do |pricing|
            {
              id: pricing.id,
              unit_configuration: pricing.unit_configuration.name,
              price: pricing.price,
              discount_percentage: pricing.discount_percentage,
              tax_percentage: pricing.tax_percentage,
              final_price: pricing.final_price
            }
          end
        }
      end
    end
  end

  # GET /service_subcategories/1/available_slots?date=2025-07-01
  def available_slots
    date = Date.parse(params[:date]) rescue Date.current

    unless @service_subcategory.can_book_for_date?(date)
      return render json: { 
        error: "Cannot book for this date. Minimum #{@service_subcategory.advance_booking_hours} hours advance booking required." 
      }, status: :unprocessable_entity
    end

    available_slots = @service_subcategory.available_slots_for_date(date)

    render json: {
      date: date,
      available_slots: available_slots.map do |slot|
        {
          id: slot.id,
          start_time: slot.start_time.strftime('%H:%M'),
          end_time: slot.end_time.strftime('%H:%M'),
          display_time: slot.display_time,
          available_spots: slot.available_spots_for_date(date),
          max_bookings: slot.max_bookings
        }
      end
    }
  end

  # GET /service_subcategories/1/pricing_info?unit_configuration_id=1
  def pricing_info
    unit_config_id = params[:unit_configuration_id]
    
    # If no unit_configuration_id provided, try to get it from user's unit
    if unit_config_id.blank?
      user_unit = @user.unit
      if user_unit&.unit_configuration_id
        unit_config_id = user_unit.unit_configuration_id
      else
        return render json: { 
          error: "Your unit configuration is not set. Please contact admin.", 
          user_unit_configured: false 
        }, status: :unprocessable_entity
      end
    end

    pricing = @service_subcategory.price_for_unit_configuration(unit_config_id)
    
    unless pricing
      return render json: { error: "Pricing not configured for this unit type" }, status: :not_found
    end

    render json: {
      pricing: {
        id: pricing.id,
        unit_configuration: pricing.unit_configuration.name,
        **pricing.price_breakdown
      },
      user_unit_configured: true
    }
  end

  # GET /service_subcategories/new
  def new
    @service_subcategory = ServiceSubcategory.new
    @service_categories = ServiceCategory.for_site(@user.current_site_id).active.ordered
  end

  # GET /service_subcategories/1/edit
  def edit
    @service_categories = ServiceCategory.for_site(@user.current_site_id).active.ordered
  end

  # POST /service_subcategories
  # POST /service_subcategories.json
  def create
    @service_subcategory = ServiceSubcategory.new(service_subcategory_params)
    @service_subcategory.site_id = @user.current_site_id

    respond_to do |format|
      if @service_subcategory.save
        format.html { redirect_to @service_subcategory, notice: 'Service subcategory was successfully created.' }
        format.json { render json: @service_subcategory, status: :created }
      else
        format.html do
          @service_categories = ServiceCategory.for_site(@user.current_site_id).active.ordered
          render :new
        end
        format.json { render json: @service_subcategory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_subcategories/1
  # PATCH/PUT /service_subcategories/1.json
  def update
    respond_to do |format|
      if @service_subcategory.update(service_subcategory_params)
        format.html { redirect_to @service_subcategory, notice: 'Service subcategory was successfully updated.' }
        format.json { render json: @service_subcategory }
      else
        format.html do
          @service_categories = ServiceCategory.for_site(@user.current_site_id).active.ordered
          render :edit
        end
        format.json { render json: @service_subcategory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_subcategories/1
  # DELETE /service_subcategories/1.json
  def destroy
    @service_subcategory.update(active: false)
    
    respond_to do |format|
      format.html { redirect_to service_subcategories_url, notice: 'Service subcategory was successfully deactivated.' }
      format.json { head :no_content }
    end
  end

  # GET /service_subcategories/check_user_unit_config
  def check_user_unit_config
    user_unit = @user.unit
    
    if user_unit.nil?
      return render json: { 
        configured: false, 
        error: "No unit assigned to user" 
      }, status: :unprocessable_entity
    end
    
    if user_unit.unit_configuration_id.nil?
      return render json: { 
        configured: false, 
        error: "Your unit configuration is not set. Please contact admin.",
        unit: {
          id: user_unit.id,
          name: user_unit.name
        }
      }, status: :unprocessable_entity
    end
    
    render json: {
      configured: true,
      unit: {
        id: user_unit.id,
        name: user_unit.name,
        unit_configuration_id: user_unit.unit_configuration_id,
        unit_configuration_name: user_unit.unit_configuration_name
      }
    }
  end

  private

  def set_service_subcategory
    @service_subcategory = ServiceSubcategory.find(params[:id])
  end

  def service_subcategory_params
    params.require(:service_subcategory).permit(:name, :description, :terms_and_conditions, :duration_minutes, 
                                                :advance_booking_hours, :cancellation_hours, :sort_order, 
                                                :active, :service_category_id)
  end
end
