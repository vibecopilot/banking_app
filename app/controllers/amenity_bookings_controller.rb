class AmenityBookingsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :set_user
  before_action :set_amenity_booking, only: %i[ show edit update destroy]
  skip_before_action :verify_authenticity_token, only: [:mark_as_read]
  # GET /amenity_bookings or /amenity_bookings.json
  def index
    base = AmenityBooking.joins(:amenity, :user).where(site_id: @user.current_site_id)
    # Month-wise-filtering
    if params[:from_month].present? && params[:to_month].present?
      year       = params[:year].presence || Date.current.year
      start_date = Date.new(year.to_i, params[:from_month].to_i, 1)
      end_date   = Date.new(year.to_i, params[:to_month].to_i, 1).end_of_month
      base = base.where(booking_date: start_date..end_date)
    end
    if @user.pms_admin?
      @amenity_bookings =  base.ransack(params[:q]).result.includes(:amenity, :amenity_slot, :amenity_notifications).order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
    else
      @amenity_bookings = base.ransack(params[:q]).result.includes(:amenity, :amenity_slot, :amenity_notifications).order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
    end
  end

  def export_amenity
    # binding.pry
    unless params[:start_date].present? && params[:end_date].present?
      return redirect_to amenity_bookings_path, alert: "Please select date range"
    end
    start_date = Date.parse(params[:start_date])
    end_date   = Date.parse(params[:end_date])
    @amenity_bookings = AmenityBooking.where(
      site_id: @user.current_site_id,
      booking_date: start_date.beginning_of_day..end_date.end_of_day
    )
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] =
        "attachment; filename=amenity_bookings_#{Time.current.strftime('%Y%m%d_%H%M%S')}.xlsx"

        render xlsx: 'export_amenity',
        template: 'amenity_bookings/export_amenity'
      }
    end
  end


  def all_records_of_amenity
    # binding.pry
    if @user.pms_admin?
      @amenity_bookings = AmenityBooking
      .where(site_id: @user.current_site_id)
      .joins(:amenity)
      .where('amenities.is_hotel IS NULL OR amenities.is_hotel = ?', false)
      .includes(:amenity, :amenity_slot, :amenity_notifications)
      .references(:amenity)
      .order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
    else
      @amenity_bookings = AmenityBooking
      .where(site_id: @user.current_site_id, user_id: @user.id)
      .joins(:amenity)
      .where('amenities.is_hotel IS NULL OR amenities.is_hotel = ?', false)
      .includes(:amenity, :amenity_slot, :amenity_notifications)
      .references(:amenity)
      .order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
    end
    respond_to do |format|
      format.json { render 'index' }
    end
  end

  # GET /amenity_bookings/1 or /amenity_bookings/1.json
  def show
  end

  # GET /amenity_bookings/new
  def new
    @amenity_booking = AmenityBooking.new
  end

  # GET /amenity_bookings/1/edit
  def edit
  end

  # POST /amenity_bookings or /amenity_bookings.json
  def create
    @amenity_booking = AmenityBooking.new(amenity_booking_params)
    @amenity_booking.status = "booked"
    respond_to do |format|
      if @amenity_booking.save

        existing_notify = AmenityNotification.find_by(
          user_id: @amenity_booking.user_id,
          # amenity_booking_id: @amenity_booking.amenity_id,
          amenity_id: @amenity_booking.amenity_id,
          read: false
        )
        unless existing_notify
          AmenityNotification.create!(
            user_id: @amenity_booking.user_id,
            amenity_booking_id: @amenity_booking.id,
            amenity_id: @amenity_booking.amenity_id,
            message: "You have a new facility booking for #{@amenity_booking&.amenity&.fac_name}",
            read: false
          )
        end

        format.html { redirect_to @amenity_booking, notice: "Amenity booking was successfully created." }
        format.json { render json: { message: "Amenity booking was successfully created.", booking_id: @amenity_booking.id }, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @amenity_booking.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def calender_booking
    @q = AmenityBooking.joins(:amenity).includes(:amenity, :user).ransack(params[:q])
    @bookings = @q.result.page(params[:page]).per(params[:per_page] || 50)
    # Booking Type Filter
    case params[:booking_type]
    when "guest_room"
      @bookings = @bookings.where(amenities: { is_hotel: true })
    when "amenity"
      @bookings = @bookings.where(
        "amenities.is_hotel IS NULL OR amenities.is_hotel = ?", false
      )
    end

    # Date Filtering (Month / Week / Day / Agenda)

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date   = Date.parse(params[:end_date])
    else
      # Default → Current Month
      start_date = Date.today.beginning_of_month
      end_date   = Date.today.end_of_month
    end


    @bookings = @bookings.where(
      "(checkin_at BETWEEN ? AND ?)
     OR (checkout_at BETWEEN ? AND ?)
     OR (booking_date BETWEEN ? AND ?)",
      start_date, end_date,
      start_date, end_date,
      start_date, end_date
    )


    @colors = [
      "#FF5733","#33B5E5","#2ECC71","#FFC300","#9B59B6",
      "#FF9800","#E91E63","#00BCD4","#8BC34A","#607D8B"
    ]


    respond_to do |format|
      format.json { render 'calender_hotel_booking' }
    end

  end




  # PATCH/PUT /amenity_bookings/1 or /amenity_bookings/1.json
  def update
    respond_to do |format|
      if @amenity_booking.update(amenity_booking_params)
        format.html { redirect_to @amenity_booking, notice: "Amenity booking was successfully updated." }
        format.json { render :show, status: :ok, location: @amenity_booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @amenity_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /amenity_bookings/1 or /amenity_bookings/1.json
  def destroy
    @amenity_booking.destroy
    respond_to do |format|
      format.html { redirect_to amenity_bookings_url, notice: "Amenity booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def notification_amenity
    @amenity_notifications = AmenityNotification.includes(:user).where(user_id: @user.id).order(created_at: :desc)

    respond_to do |format|
      format.json { render "amenity_notification" }
    end
  end

  def mark_as_read
    notification_id = params[:amenity_booking][:amenity_notifications][:id] || params[:amenity_booking][:amenity_notifications][:ids]
    if notification_id.present?
      AmenityNotification.where(id: notification_id).update_all(read: true)
      render json: { success: true, message: "Notification(s) marked as read." }
    else
      render json: { success: false, error: "Notification ID not provided" }, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_amenity_booking
    @amenity_booking = AmenityBooking.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def amenity_booking_params
    params.require(:amenity_booking).permit(:amenity_id, :is_book_hotel, :checkout_at ,:checkin_at ,:amenity_slot_id, :user_id, :booking_date, :site_id,:amount,:member_adult,:member_child,:guest_adult,:guest_child,:no_of_members,:no_of_guests, :status, :payment_mode,:tenant_adult, :tenant_child, :no_of_tenants)
  end
end
