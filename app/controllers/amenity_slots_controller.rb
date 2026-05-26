class AmenitySlotsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_activity, only: %i[ show edit update destroy ]
  before_action :set_amenity_slot, only: %i[ show edit update destroy ]

  # GET /amenity_slots or /amenity_slots.json
  def index
    @amenity_slots = AmenitySlot.where(amenity_id: params[:amenity_id])
  end

  # GET /amenity_slots/booked_slots
  # Shows all slots with their booking and user details
  # Optional params: amenity_id, date, from_date, to_date
  def booked_slots
    bookings = AmenityBooking
      .joins(:amenity, :amenity_slot, :user)
      .where(site_id: @user.current_site_id)
      .where.not(amenity_slot_id: nil)
      .includes(:amenity, :amenity_slot, :user)

    # Filter by amenity if provided
    bookings = bookings.where(amenity_id: params[:amenity_id]) if params[:amenity_id].present?

    # Filter by specific date
    bookings = bookings.where(booking_date: params[:date]) if params[:date].present?

    # Filter by date range
    if params[:from_date].present? && params[:to_date].present?
      bookings = bookings.where(booking_date: params[:from_date]..params[:to_date])
    end

    # Filter by status
    bookings = bookings.where(status: params[:status]) if params[:status].present?

    # Order by booking date and slot time
    bookings = bookings.order(booking_date: :asc, created_at: :desc)

    # Pagination
    bookings = bookings.page(params[:page]).per(params[:per_page] || 50)

    @booked_slots = bookings.map do |booking|
      {
        booking_id: booking.id,
        booking_date: booking.booking_date,
        status: booking.status,
        amount: booking.amount,
        payment_mode: booking.payment_mode,
        created_at: booking.created_at,
        amenity: {
          id: booking.amenity&.id,
          name: booking.amenity&.fac_name,
          type: booking.amenity&.fac_type,
          is_hotel: booking.amenity&.is_hotel
        },
        slot: {
          id: booking.amenity_slot&.id,
          start_time: format_slot_time(booking.amenity_slot&.start_hr, booking.amenity_slot&.start_min),
          end_time: format_slot_time(booking.amenity_slot&.end_hr, booking.amenity_slot&.end_min),
          start_hr: booking.amenity_slot&.start_hr,
          start_min: booking.amenity_slot&.start_min,
          end_hr: booking.amenity_slot&.end_hr,
          end_min: booking.amenity_slot&.end_min
        },
        user: {
          id: booking.user&.id,
          name: booking.user&.full_name,
          email: booking.user&.email,
          mobile: booking.user&.mobile,
          unit: booking.user&.unit&.name,
          address: booking.user&.full_unit_name
        },
        members: {
          member_adult: booking.member_adult,
          member_child: booking.member_child,
          guest_adult: booking.guest_adult,
          guest_child: booking.guest_child,
          tenant_adult: booking.tenant_adult,
          tenant_child: booking.tenant_child,
          no_of_members: booking.no_of_members,
          no_of_guests: booking.no_of_guests,
          no_of_tenants: booking.no_of_tenants
        }
      }
    end

    respond_to do |format|
      format.json { 
        render json: {
          booked_slots: @booked_slots,
          total_count: bookings.total_count,
          current_page: bookings.current_page,
          total_pages: bookings.total_pages,
          per_page: bookings.limit_value
        }
      }
    end
  end

  # GET /amenity_slots/slots_summary
  # Shows summary of slots for an amenity on a specific date
  def slots_summary
    unless params[:amenity_id].present? && params[:date].present?
      render json: { error: "amenity_id and date are required" }, status: :unprocessable_entity and return
    end

    amenity = Amenity.find_by(id: params[:amenity_id])
    unless amenity
      render json: { error: "Amenity not found" }, status: :not_found and return
    end

    target_date = params[:date].to_date

    # Get all slots for this amenity
    all_slots = amenity.amenity_slots

    # Get booked slots for this date
    booked_bookings = AmenityBooking
      .where(amenity_id: params[:amenity_id], booking_date: target_date)
      .where.not(amenity_slot_id: nil)
      .where(status: ['booked', 'confirmed'])
      .includes(:amenity_slot, :user)

    booked_slot_ids = booked_bookings.pluck(:amenity_slot_id)

    slots_data = all_slots.map do |slot|
      booking = booked_bookings.find { |b| b.amenity_slot_id == slot.id }
      
      {
        slot_id: slot.id,
        start_time: format_slot_time(slot.start_hr, slot.start_min),
        end_time: format_slot_time(slot.end_hr, slot.end_min),
        is_booked: booked_slot_ids.include?(slot.id),
        booking: booking ? {
          booking_id: booking.id,
          status: booking.status,
          amount: booking.amount,
          booked_by: {
            user_id: booking.user&.id,
            name: booking.user&.full_name,
            email: booking.user&.email,
            mobile: booking.user&.mobile
          },
          booked_at: booking.created_at
        } : nil
      }
    end

    respond_to do |format|
      format.json {
        render json: {
          amenity: {
            id: amenity.id,
            name: amenity.fac_name,
            type: amenity.fac_type
          },
          date: target_date,
          total_slots: all_slots.count,
          booked_slots_count: booked_slot_ids.count,
          available_slots_count: all_slots.count - booked_slot_ids.count,
          slots: slots_data
        }
      }
    end
  end

  # GET /amenity_slots/1 or /amenity_slots/1.json
  def show
  end

  # GET /amenity_slots/new
  def new
    @amenity_slot = AmenitySlot.new
  end

  # GET /amenity_slots/1/edit
  def edit
  end

  # POST /amenity_slots or /amenity_slots.json
  def create
    @amenity_slot = AmenitySlot.new(amenity_slot_params)

    respond_to do |format|
      if @amenity_slot.save
        format.html { redirect_to @amenity_slot, notice: "Amenity slot was successfully created." }
        format.json { render :show, status: :created, location: @amenity_slot }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @amenity_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /amenity_slots/1 or /amenity_slots/1.json
  def update
    respond_to do |format|
      if @amenity_slot.update(amenity_slot_params)
        format.html { redirect_to @amenity_slot, notice: "Amenity slot was successfully updated." }
        format.json { render :show, status: :ok, location: @amenity_slot }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @amenity_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /amenity_slots/1 or /amenity_slots/1.json
  def destroy
    @amenity_slot.destroy
    respond_to do |format|
      format.html { redirect_to amenity_slots_url, notice: "Amenity slot was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_amenity_slot
      @amenity_slot = AmenitySlot.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def amenity_slot_params
      params.require(:amenity_slot).permit(:amenity_id, :start_hr, :end_hr, :start_min, :end_min)
    end

    # Format slot time as HH:MM AM/PM
    def format_slot_time(hr, min)
      return nil if hr.nil?
      time = Time.new(2000, 1, 1, hr.to_i, min.to_i || 0)
      time.strftime("%I:%M %p")
    end
end
