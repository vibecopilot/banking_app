class ServiceBookingsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_service_booking, only: [:show, :edit, :update, :destroy, :cancel, :rate]

  # GET /service_bookings
  # GET /service_bookings.json
 def index
  # Build Ransack search
  @q = ServiceBooking.for_user(@user.id)
                     .includes(:service_subcategory, :service_slot, :unit)
                     .ransack(params[:q])

  # Apply filters via Ransack result
  @service_bookings = @q.result
                        .order(booking_date: :desc, created_at: :desc)

  # Additional custom filters
  @service_bookings = @service_bookings.where(status: params[:status]) if params[:status].present?
  @service_bookings = @service_bookings.upcoming if params[:upcoming] == 'true'
  @service_bookings = @service_bookings.past if params[:past] == 'true'

  # Pagination (using Kaminari or WillPaginate with per_page option)
  @service_bookings = @service_bookings.page(params[:page]).per(params[:per_page] || 100)

  respond_to do |format|
    format.html
    format.json { render 'index' }
  end
end


  # GET /service_bookings/1
  # GET /service_bookings/1.json
  # def show
  #   respond_to do |format|
  #     format.html
  #     format.json do
  #       render json: {
  #         id: @service_booking.id,
  #         booking_date: @service_booking.booking_date,
  #         status: @service_booking.status,
  #         display_status: @service_booking.display_status,
  #         service: {
  #           id: @service_booking.service_subcategory.id,
  #           name: @service_booking.service_subcategory.name,
  #           category_name: @service_booking.service_subcategory.service_category.name,
  #           description: @service_booking.service_subcategory.description,
  #           duration_minutes: @service_booking.service_subcategory.duration_minutes
  #         },
  #         time_slot: {
  #           id: @service_booking.service_slot.id,
  #           display_time: @service_booking.service_slot.display_time,
  #           start_time: sprintf("%02d:%02d", @service_booking.service_slot.start_hr, @service_booking.service_slot.start_min),
  #           end_time: sprintf("%02d:%02d", @service_booking.service_slot.end_hr, @service_booking.service_slot.end_min)
  #         },
  #         unit: {
  #           id: @service_booking.unit.id,
  #           name: @service_booking.unit.name,
  #           full_address: @service_booking.unit.full_address
  #         },
  #         pricing: {
  #           total_amount: @service_booking.total_amount,
  #           discount_amount: @service_booking.discount_amount,
  #           tax_amount: @service_booking.tax_amount,
  #           final_amount: @service_booking.final_amount
  #         },
  #         payment_status: @service_booking.payment_status,
  #         special_instructions: @service_booking.special_instructions,
  #         can_cancel: @service_booking.can_be_cancelled?,
  #         can_rate: @service_booking.can_rate?,
  #         rating: @service_booking.rating,
  #         feedback: @service_booking.feedback,
  #         service_started_at: @service_booking.service_started_at,
  #         service_completed_at: @service_booking.service_completed_at,
  #         created_at: @service_booking.created_at
  #       }
  #     end
  #   end
  # end

  def show
  respond_to do |format|
    format.html
    format.json
  end
end

  # GET /service_bookings/new
  def new
    @service_booking = ServiceBooking.new
    @service_categories = ServiceCategory.for_site(@user.current_site_id).active.ordered
  end

  # POST /service_bookings
  # POST /service_bookings.json
  def create
    booking_params = service_booking_params
    
    # Get user's unit and its configuration
    user_unit = get_user_unit
    
    unless user_unit
      return render json: { 
        error: "You don't have a unit assigned. Please contact admin to assign a unit to your account.",
        error_code: "NO_UNIT_ASSIGNED",
        debug_info: {
          user_id: @user.id,
          user_email: @user.email,
          unit_id: nil,
          user_sites_count: @user.user_sites.count,
          approved_user_sites: @user.user_sites.where(is_approved: true).count
        }
      }, status: :unprocessable_entity
    end
    
    unless user_unit.unit_configuration_id
      return render json: { 
        error: "Your unit doesn't have a configuration set. Please contact admin to set up your unit configuration.",
        error_code: "NO_UNIT_CONFIGURATION",
        debug_info: {
          user_id: @user.id,
          unit_id: user_unit.id,
          unit_name: user_unit.name,
          unit_configuration_id: user_unit.unit_configuration_id
        }
      }, status: :unprocessable_entity
    end
    
    unless user_unit.unit_configuration
      return render json: { 
        error: "Your unit configuration record is missing from the database. Please contact admin.",
        error_code: "UNIT_CONFIGURATION_MISSING",
        debug_info: {
          user_id: @user.id,
          unit_id: user_unit.id,
          unit_name: user_unit.name,
          unit_configuration_id: user_unit.unit_configuration_id
        }
      }, status: :unprocessable_entity
    end

    # Validate service subcategory exists and belongs to user's site
    service_subcategory = ServiceSubcategory.find_by(id: booking_params[:service_subcategory_id])
    unless service_subcategory && service_subcategory.site_id == @user.current_site_id
      return render json: { error: "Service not found" }, status: :not_found
    end

    # Validate service slot exists and belongs to the subcategory
    service_slot = ServiceSlot.find_by(id: booking_params[:service_slot_id])
    unless service_slot && service_slot.service_subcategory_id == service_subcategory.id
      return render json: { error: "Service slot not found" }, status: :not_found
    end

    # Check if booking date is valid
    booking_date = Date.parse(booking_params[:booking_date]) rescue nil
    unless booking_date
      return render json: { error: "Invalid booking date" }, status: :unprocessable_entity
    end

    # Check if booking date is not in the past
    if booking_date < Date.current
      return render json: { error: "Cannot book for past dates" }, status: :unprocessable_entity
    end

    # Check advance booking requirements
    unless service_subcategory.can_book_for_date?(booking_date)
      hours_required = service_subcategory.advance_booking_hours
      return render json: { error: "Booking must be made at least #{hours_required} hours in advance" }, status: :unprocessable_entity
    end

    # Check slot availability for the date
    unless service_slot.available_on_date?(booking_date)
      return render json: { error: "Selected time slot is not available for this date" }, status: :unprocessable_entity
    end

    # Get the service pricing for user's unit configuration
    service_pricing = ServicePricing.find_by(
      service_subcategory_id: booking_params[:service_subcategory_id],
      unit_configuration_id: user_unit.unit_configuration_id,
      active: true
    )

    unless service_pricing
      return render json: { error: "Pricing not available for your unit type" }, status: :unprocessable_entity
    end

    # Check for duplicate booking (same user, service, date, slot)
    existing_booking = ServiceBooking.find_by(
      user: @user,
      service_subcategory: service_subcategory,
      service_slot: service_slot,
      booking_date: booking_date,
      status: ['pending', 'confirmed', 'in_progress']
    )

    if existing_booking
      return render json: { error: "You already have a booking for this service at this time" }, status: :unprocessable_entity
    end

    @service_booking = ServiceBooking.new(booking_params)
    @service_booking.user = @user
    @service_booking.unit = user_unit
    @service_booking.service_pricing = service_pricing
    @service_booking.status = 'pending'
    @service_booking.payment_status = 'pending'

    respond_to do |format|
      if @service_booking.save
        format.html { redirect_to @service_booking, notice: 'Service booking was successfully created.' }
        format.json do
          render json: {
            id: @service_booking.id,
            booking_date: @service_booking.booking_date,
            status: @service_booking.status,
            display_status: @service_booking.display_status,
            service: {
              id: service_subcategory.id,
              name: service_subcategory.name,
              category_name: service_subcategory.service_category.name
            },
            time_slot: {
              id: service_slot.id,
              display_time: service_slot.display_time
            },
            unit: {
              id: user_unit.id,
              name: user_unit.name
            },
            pricing: service_pricing.price_breakdown.merge(
              total_amount: @service_booking.total_amount,
              final_amount: @service_booking.final_amount
            ),
            payment_status: @service_booking.payment_status,
            special_instructions: @service_booking.special_instructions,
            created_at: @service_booking.created_at
          }, status: :created
        end
      else
        format.html do
          @service_categories = ServiceCategory.for_site(@user.current_site_id).active.ordered
          render :new
        end
        format.json { render json: { errors: @service_booking.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_bookings/1
  # PATCH/PUT /service_bookings/1.json
  def update
    respond_to do |format|
      if @service_booking.update(service_booking_update_params)
        format.html { redirect_to @service_booking, notice: 'Service booking was successfully updated.' }
        format.json { render json: @service_booking }
      else
        format.html { render :edit }
        format.json { render json: @service_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_bookings/1
  # DELETE /service_bookings/1.json
  def destroy
    @service_booking.destroy
    
    respond_to do |format|
      format.html { redirect_to service_bookings_url, notice: 'Service booking was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # POST /service_bookings/1/cancel
  def cancel
    cancellation_reason = params[:cancellation_reason]

    if @service_booking.cancel_booking!(cancellation_reason)
      render json: { message: "Booking cancelled successfully", status: @service_booking.status }
    else
      render json: { error: "Cannot cancel this booking", errors: @service_booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /service_bookings/1/confirm
  def confirm
    unless @service_booking.status == 'pending'
      return render json: { error: "Only pending bookings can be confirmed" }, status: :unprocessable_entity
    end

    if @service_booking.update(status: 'confirmed')
      render json: { message: "Booking confirmed successfully", status: @service_booking.status }
    else
      render json: { error: "Could not confirm booking", errors: @service_booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /service_bookings/1/start
  def start
    unless @service_booking.status == 'confirmed'
      return render json: { error: "Only confirmed bookings can be started" }, status: :unprocessable_entity
    end

    if @service_booking.update(status: 'in_progress', service_started_at: Time.current)
      render json: { message: "Service started successfully", status: @service_booking.status }
    else
      render json: { error: "Could not start service", errors: @service_booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /service_bookings/1/complete
  def complete
    unless @service_booking.status == 'in_progress'
      return render json: { error: "Only in-progress bookings can be completed" }, status: :unprocessable_entity
    end

    if @service_booking.update(status: 'completed', service_completed_at: Time.current)
      render json: { message: "Service completed successfully", status: @service_booking.status }
    else
      render json: { error: "Could not complete service", errors: @service_booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /service_bookings/1/rate
  def rate
    rating = params[:rating]
    feedback = params[:feedback]

    unless @service_booking.can_rate?
      return render json: { error: "Cannot rate this booking" }, status: :unprocessable_entity
    end

    if @service_booking.update(rating: rating, feedback: feedback)
      render json: { message: "Rating submitted successfully" }
    else
      render json: { error: @service_booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /service_bookings/user_configuration_status
  def user_configuration_status
    user_unit = get_user_unit
    
    unit_configurations = UnitConfiguration.where(active: true, site_id: @user.current_site_id)
    
    status = {
      user: {
        id: @user.id,
        email: @user.email,
        name: "#{@user.firstname} #{@user.lastname}",
        current_site_id: @user.current_site_id
      },
      unit_assigned: user_unit.present?,
      unit_configured: user_unit&.unit_configuration_id.present?,
      unit_configuration_valid: user_unit&.unit_configuration.present?,
      available_unit_configurations: unit_configurations.map { |uc| { id: uc.id, name: uc.name, description: uc.description } },
      unit_source: user_unit ? (@user.unit ? "direct_assignment" : "user_sites") : nil
    }
    
    if user_unit
      status[:unit] = {
        id: user_unit.id,
        name: user_unit.name,
        unit_configuration_id: user_unit.unit_configuration_id,
        unit_configuration_name: user_unit.unit_configuration&.name
      }
    end
    
    # Determine if user can book services
    status[:can_book_services] = status[:unit_assigned] && status[:unit_configured] && status[:unit_configuration_valid]
    
    # Provide guidance
    unless status[:can_book_services]
      if !status[:unit_assigned]
        status[:guidance] = "Contact admin to assign a unit to your account"
      elsif !status[:unit_configured]
        status[:guidance] = "Contact admin to set unit configuration for your unit"
      elsif !status[:unit_configuration_valid]
        status[:guidance] = "Contact admin - unit configuration record is missing"
      end
    end
    
    render json: status
  end

  # GET /service_bookings/available_services
  def available_services
    date = Date.parse(params[:date]) rescue Date.current
    user_unit = get_user_unit

    unless user_unit&.unit_configuration
      return render json: { error: "Your unit configuration is not set" }, status: :unprocessable_entity
    end

    categories = ServiceCategory.for_site(@user.current_site_id)
                               .active
                               .ordered
                               .includes(service_subcategories: [:service_slots, :service_pricings])

    available_services = categories.map do |category|
      subcategories = category.service_subcategories.active.map do |subcategory|
        next unless subcategory.can_book_for_date?(date)
        
        available_slots = subcategory.service_slots.active.select { |slot| slot.available_on_date?(date) }
        pricing = subcategory.service_pricings.find_by(unit_configuration_id: user_unit.unit_configuration_id, active: true)
        
        next unless available_slots.any? && pricing

        {
          id: subcategory.id,
          name: subcategory.name,
          description: subcategory.description,
          duration_minutes: subcategory.duration_minutes,
          advance_booking_hours: subcategory.advance_booking_hours,
          available_slots: available_slots.map do |slot|
            {
              id: slot.id,
              start_time: sprintf("%02d:%02d", slot.start_hr, slot.start_min),
              end_time: sprintf("%02d:%02d", slot.end_hr, slot.end_min),
              display_time: slot.display_time,
              available_spots: slot.available_spots_for_date(date)
            }
          end,
          pricing: pricing.price_breakdown
        }
      end.compact

      next if subcategories.empty?

      {
        id: category.id,
        name: category.name,
        description: category.description,
        icon_url: category.icon_url,
        subcategories: subcategories
      }
    end.compact

    render json: {
      date: date,
      user_unit_type: user_unit.unit_configuration.name,
      available_services: available_services
    }
  end

  # POST /service_bookings/assign_test_unit (for development/testing only)
  def assign_test_unit
    # This should only be available in development
    unless Rails.env.development?
      return render json: { error: "This endpoint is only available in development" }, status: :forbidden
    end
    
    unit_id = params[:unit_id]
    unit_configuration_id = params[:unit_configuration_id]
    
    unit = Unit.find_by(id: unit_id)
    unit_configuration = UnitConfiguration.find_by(id: unit_configuration_id)
    
    unless unit
      return render json: { error: "Unit not found" }, status: :not_found
    end
    
    unless unit_configuration
      return render json: { error: "Unit configuration not found" }, status: :not_found
    end
    
    # Assign unit to user
    @user.update(unit: unit)
    
    # Assign configuration to unit
    unit.update(unit_configuration: unit_configuration)
    
    render json: {
      message: "Unit and configuration assigned successfully",
      user: {
        id: @user.id,
        email: @user.email,
        unit_id: @user.unit_id
      },
      unit: {
        id: unit.id,
        name: unit.name,
        unit_configuration_id: unit.unit_configuration_id,
        unit_configuration_name: unit.unit_configuration.name
      }
    }
  end

  private

  def get_user_unit
    user_unit = @user.unit
    
    # If no direct unit assignment, check user_sites for unit assignment
    if user_unit.nil?
      user_site = @user.user_sites.where(is_approved: true, lives_here: true).first
      if user_site&.unit_id
        user_unit = Unit.find_by(id: user_site.unit_id)
      end
    end
    
    user_unit
  end

  def set_service_booking
    @service_booking = ServiceBooking.find(params[:id])
    
    # Ensure user can only access their own bookings
    unless @service_booking.user_id == @user.id || @user.user_type == 'pms_admin'
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def service_booking_params
    params.require(:service_booking).permit(:booking_date, :payment_status ,:payment_method, :transaction_id, :special_instructions, :service_subcategory_id, :service_slot_id, :unit_configuration_id, :service_pricing_id)
  end

  def service_booking_update_params
    params.require(:service_booking).permit(:special_instructions, :payment_method, :payment_status, :transaction_id)
  end
end
