class ServiceSlotsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_service_slot, only: [:show, :edit, :update, :destroy]

  # GET /service_slots
  # GET /service_slots.json
  def index
    @service_slots = ServiceSlot.joins(:service_subcategory)
    .where(service_subcategories: { site_id: @user.current_site_id })
    .active
    .ordered
    .includes(:service_subcategory)

    @service_slots = @service_slots.where(service_subcategory_id: params[:subcategory_id]) if params[:subcategory_id].present?

    respond_to do |format|
      format.html
      format.json {render 'service_slot', status: :ok}
    end
  end

  # GET /service_slots/1
  # GET /service_slots/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @service_slot }
    end
  end

  # GET /service_slots/new
  def new
    @service_slot = ServiceSlot.new
    @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
  end

  # GET /service_slots/1/edit
  def edit
    @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
  end

  # POST /service_slots
  # POST /service_slots.json
  def create
    @service_slot = ServiceSlot.new(service_slot_params)

    respond_to do |format|
      if @service_slot.save
        format.html { redirect_to @service_slot, notice: 'Service slot was successfully created.' }
        format.json { render json: @service_slot, status: :created }
      else
        format.html do
          @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
          render :new
        end
        format.json { render json: @service_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_slots/1
  # PATCH/PUT /service_slots/1.json
  def update
    respond_to do |format|
      if @service_slot.update(service_slot_params)
        format.html { redirect_to @service_slot, notice: 'Service slot was successfully updated.' }
        format.json { render json: @service_slot }
      else
        format.html do
          @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
          render :edit
        end
        format.json { render json: @service_slot.errors, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /service_slots/1
  # DELETE /service_slots/1.json
  def destroy
    @service_slot.update(active: false)

    respond_to do |format|
      format.html { redirect_to service_slots_url, notice: 'Service slot was successfully deactivated.' }
      format.json { head :no_content }
    end
  end

  # POST /service_slots/bulk_create
  # POST /service_slots/bulk_create.json
  def bulk_create
    begin
      params_data = bulk_create_params
      service_subcategory_id = params_data[:service_subcategory_id]
      start_hr = params_data[:start_hr].to_i
      start_min = params_data[:start_min].to_i
      end_hr = params_data[:end_hr].to_i
      end_min = params_data[:end_min].to_i
      slot_duration = params_data[:slot_duration].to_i
      max_bookings = params_data[:max_bookings].to_i

      # Validate service subcategory belongs to current site
      service_subcategory = ServiceSubcategory.find(service_subcategory_id)
      unless service_subcategory.site_id == @user.current_site_id
        return render json: { error: "Service subcategory not found" }, status: :not_found
      end

      # Convert to minutes for easier calculation
      start_total_minutes = start_hr * 60 + start_min
      end_total_minutes = end_hr * 60 + end_min

      # Handle case where end time is next day (e.g., 23:00 to 02:00)
      if end_total_minutes <= start_total_minutes
        end_total_minutes += 24 * 60  # Add 24 hours in minutes
      end

      created_slots = []
      errors = []

      current_minutes = start_total_minutes

      while current_minutes < end_total_minutes
        slot_end_minutes = current_minutes + slot_duration

        # Don't create slot if it would exceed the end time
        break if slot_end_minutes > end_total_minutes

        # Convert back to hour/minute format
        current_hr = (current_minutes / 60) % 24
        current_min = current_minutes % 60
        slot_end_hr = (slot_end_minutes / 60) % 24
        slot_end_min = slot_end_minutes % 60

        slot = ServiceSlot.new(
          service_subcategory_id: service_subcategory_id,
          start_hr: current_hr,
          start_min: current_min,
          end_hr: slot_end_hr,
          end_min: slot_end_min,
          max_bookings: max_bookings,
          active: true
        )

        if slot.save
          created_slots << slot
        else
          errors << {
            start_time: sprintf("%02d:%02d", current_hr, current_min),
            end_time: sprintf("%02d:%02d", slot_end_hr, slot_end_min),
            errors: slot.errors.full_messages
          }
        end

        current_minutes = slot_end_minutes
      end

      if errors.empty?
        render json: {
          message: "Successfully created #{created_slots.count} slots",
          slots: created_slots.map do |slot|
            {
              id: slot.id,
              start_hr: slot.start_hr,
              start_min: slot.start_min,
              end_hr: slot.end_hr,
              end_min: slot.end_min,
              start_time: sprintf("%02d:%02d", slot.start_hr, slot.start_min),
              end_time: sprintf("%02d:%02d", slot.end_hr, slot.end_min),
              display_time: slot.display_time,
              max_bookings: slot.max_bookings
            }
          end
        }, status: :created
      else
        render json: {
          message: "Created #{created_slots.count} slots with some errors",
          slots: created_slots.map do |slot|
            {
              id: slot.id,
              start_hr: slot.start_hr,
              start_min: slot.start_min,
              end_hr: slot.end_hr,
              end_min: slot.end_min,
              start_time: sprintf("%02d:%02d", slot.start_hr, slot.start_min),
              end_time: sprintf("%02d:%02d", slot.end_hr, slot.end_min),
              display_time: slot.display_time,
              max_bookings: slot.max_bookings
            }
          end,
          errors: errors
        }, status: :partial_content
      end

    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # GET /service_slots/available_slots
  def available_slots
    date = Date.parse(params[:date]) rescue Date.current
    service_subcategory_id = params[:service_subcategory_id]

    unless service_subcategory_id.present?
      return render json: { error: "service_subcategory_id is required" }, status: :bad_request
    end

    # Validate service subcategory belongs to current site
    service_subcategory = ServiceSubcategory.find_by(id: service_subcategory_id)
    unless service_subcategory && service_subcategory.site_id == @user.current_site_id
      return render json: { error: "Service subcategory not found" }, status: :not_found
    end

    # Get all active slots for this subcategory
    slots = service_subcategory.service_slots.active.ordered

    available_slots = slots.select { |slot| slot.available_on_date?(date) }.map do |slot|
      {
        id: slot.id,
        start_time: sprintf("%02d:%02d", slot.start_hr, slot.start_min),
        end_time: sprintf("%02d:%02d", slot.end_hr, slot.end_min),
        display_time: slot.display_time,
        max_bookings: slot.max_bookings,
        current_bookings: slot.bookings_count_for_date(date),
        available_spots: slot.available_spots_for_date(date)
      }
    end

    render json: {
      date: date,
      service_subcategory: {
        id: service_subcategory.id,
        name: service_subcategory.name
      },
      available_slots: available_slots
    }
  end

  private

  def set_service_slot
    @service_slot = ServiceSlot.find(params[:id])
  end

  def service_slot_params
    permitted_params = params.require(:service_slot).permit(:start_time, :end_time, :max_bookings, :active, :service_subcategory_id, :start_hr, :end_hr, :start_min, :end_min)

    # If start_time and end_time are provided (datetime strings), parse them to hour/minute fields
    if permitted_params[:start_time].present? && !permitted_params[:start_hr].present?
      begin
        datetime = DateTime.parse(permitted_params[:start_time])
        permitted_params[:start_hr] = datetime.hour
        permitted_params[:start_min] = datetime.min
        # Keep the old time field for backward compatibility
        permitted_params[:start_time] = Time.parse(sprintf("%02d:%02d", datetime.hour, datetime.min))
      rescue
        # If parsing fails, keep original value
      end
    end

    if permitted_params[:end_time].present? && !permitted_params[:end_hr].present?
      begin
        datetime = DateTime.parse(permitted_params[:end_time])
        permitted_params[:end_hr] = datetime.hour
        permitted_params[:end_min] = datetime.min
        # Keep the old time field for backward compatibility
        permitted_params[:end_time] = Time.parse(sprintf("%02d:%02d", datetime.hour, datetime.min))
      rescue
        # If parsing fails, keep original value
      end
    end

    # If hour/minute fields are set but time fields are not, create time fields
    if permitted_params[:start_hr].present? && permitted_params[:start_min].present? && !permitted_params[:start_time].present?
      permitted_params[:start_time] = Time.parse(sprintf("%02d:%02d", permitted_params[:start_hr], permitted_params[:start_min]))
    end

    if permitted_params[:end_hr].present? && permitted_params[:end_min].present? && !permitted_params[:end_time].present?
      permitted_params[:end_time] = Time.parse(sprintf("%02d:%02d", permitted_params[:end_hr], permitted_params[:end_min]))
    end

    permitted_params
  end

  def bulk_create_params
    permitted_params = params.require(:service_slot).permit(:service_subcategory_id, :start_time, :end_time, :slot_duration, :max_bookings, :start_hr, :end_hr, :start_min, :end_min)

    # Parse datetime strings to extract hour/minute for bulk create
    if permitted_params[:start_time].present? && !permitted_params[:start_hr].present?
      begin
        datetime = DateTime.parse(permitted_params[:start_time])
        permitted_params[:start_hr] = datetime.hour
        permitted_params[:start_min] = datetime.min
      rescue
        # If parsing fails, keep original value
      end
    end

    if permitted_params[:end_time].present? && !permitted_params[:end_hr].present?
      begin
        datetime = DateTime.parse(permitted_params[:end_time])
        permitted_params[:end_hr] = datetime.hour
        permitted_params[:end_min] = datetime.min
      rescue
        # If parsing fails, keep original value
      end
    end

    permitted_params
  end
end
