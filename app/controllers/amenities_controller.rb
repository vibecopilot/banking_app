class AmenitiesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_amenity, only: %i[ show edit update destroy add_payment_methods]

  # GET /amenities or /amenities.json
  def index
    @q = Amenity.where(site_id:@user.current_site_id ).includes(:amenity_slots, :attachments, :cover_images).order(created_at: :desc).ransack(params[:q])
    @amenities = @q.result.page(params[:page]).per(params[:per_page] || 500)
  end


  # GET /amenities/1 or /amenities/1.json
  def show
  end

  # GET /amenities/new
  def new
    @amenity = Amenity.new
  end

  # GET /amenities/1/edit
  def edit
  end

  def available_slots
    # Retrieve amenity_id and target_date from request parameters
    amenity_id = params[:amenity_id]
    target_date = params[:date]

    # Ensure both parameters are present
    if amenity_id.blank? || target_date.blank?
      render json: { error: "amenity_id and date are required parameters" }, status: :unprocessable_entity
      return
    end
    if amenity_id.present?
      amenity = Amenity.find_by(id: amenity_id)
    end
    begin
      # Fetch available slots
      slots = Amenity.available_slots(amenity_id, target_date)
      render json: {amenity: amenity, slots: slots }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  # POST /amenities or /amenities.json
  def create
    @amenity = Amenity.new(sanitized_amenity_params)
    respond_to do |format|
      if @amenity.save
        # if params[:slots].present?
        #     params[:slots].each do |slot|
        #     AmenitySlot.create(amenity_id: @amenity.id,start_hr: slot[:start_hr], end_hr: slot[:end_hr], start_min: slot[:start_min],end_min: slot[:end_min])
        #   end
        # end
        if params[:attachments].present?
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "AmenityAttachmnet", relation_id: @amenity.id, active: 1)
          end
        end
        if params[:cover_images].present?
          params[:cover_images].each do |doc|
            Attachfile.create(image: doc, relation: "AmenityCoverImage", relation_id: @amenity.id, active: 1)
          end
        end
        format.html { redirect_to @amenity, notice: "Amenity was successfully created." }
        format.json { render :show, status: :created, location: @amenity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @amenity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /amenities/1 or /amenities/1.json
  def update
    respond_to do |format|
      if @amenity.update(sanitized_amenity_params)

        # Delete old attachments
        if params[:attachments].present?
          Attachfile.where(relation: "AmenityAttachmnet", relation_id: @amenity.id).destroy_all

          # Add new attachments
          params[:attachments].each do |doc|
            Attachfile.create!(
              relation: "AmenityAttachmnet",
              relation_id: @amenity.id,
              active: 1,
              image: doc
            )
          end
        end

        # Delete old cover images
        if params[:cover_images].present?
          Attachfile.where(relation: "AmenityCoverImage", relation_id: @amenity.id).destroy_all
          # Add new cover images
          params[:cover_images].each do |doc|
            Attachfile.create!(
              relation: "AmenityCoverImage",
              relation_id: @amenity.id,
              active: 1,
              image: doc
            )
          end
        end

        format.html { redirect_to @amenity, notice: "Amenity was successfully updated." }
        format.json { render :show, status: :ok, location: @amenity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @amenity.errors, status: :unprocessable_entity }
      end
    end
  end


  # Export amenities as XLSX or JSON
  def export
    @q = Amenity.where(site_id: @user.current_site_id).includes(:amenity_slots, :attachments, :cover_images).order(created_at: :desc).ransack(params[:q])
    @amenities = @q.result
    respond_to do |format|
      format.xlsx do
        filename = "amenities_#{Time.current.strftime('%Y%m%d_%H%M%S')}.xlsx"
        send_data generate_xlsx(@amenities), filename: filename, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end
      format.json do
        render json: @amenities.map { |amenity| amenity_export_json(amenity) }
      end
    end
  end

  #   def update
  #
  #   respond_to do |format|
  #     if @amenity.update(sanitized_amenity_params)
  #       # Handle attachments (only process if new files are added)
  #       if params[:attachments].present?
  #         # Remove existing Attachfile records if necessary
  #         current_attachment_ids = @amenity.attachfiles.where(relation: "AmenityAttachmnet").pluck(:id)
  #         new_attachments = params[:attachments].map(&:original_filename)  # Get filenames of newly uploaded files

  #         # Remove files that are not part of the new files
  #         @amenity.attachfiles.where(relation: "AmenityAttachmnet").where.not(original_filename: new_attachments).destroy_all

  #         params[:attachments].each do |doc|
  #           if doc.is_a?(ActionDispatch::Http::UploadedFile)
  #             Attachfile.create(image: doc, relation: "AmenityAttachmnet", relation_id: @amenity.id, active: 1)
  #           else
  #             Rails.logger.error("Invalid attachment: #{doc.inspect}")
  #           end
  #         end
  #       end

  #       # Handle cover images (only process if new files are added)
  #       if params[:cover_images].present?
  #         # Remove existing Attachfile records if necessary
  #         current_cover_image_ids = @amenity.attachfiles.where(relation: "AmenityCoverImage").pluck(:id)
  #         new_cover_images = params[:cover_images].map(&:original_filename)  # Get filenames of newly uploaded files

  #         # Remove cover images that are not part of the new files
  #         @amenity.attachfiles.where(relation: "AmenityCoverImage").where.not(original_filename: new_cover_images).destroy_all

  #         params[:cover_images].each do |doc|
  #           if doc.is_a?(ActionDispatch::Http::UploadedFile)
  #             Attachfile.create(image: doc, relation: "AmenityCoverImage", relation_id: @amenity.id, active: 1)
  #           else
  #             Rails.logger.error("Invalid cover image: #{doc.inspect}")
  #           end
  #         end
  #       end

  #       format.html { redirect_to @amenity, notice: "Amenity was successfully updated." }
  #       format.json { render :show, status: :ok, location: @amenity }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @amenity.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end


  # DELETE /amenities/1 or /amenities/1.json
  def destroy
    @amenity.destroy
    respond_to do |format|
      format.html { redirect_to amenities_url, notice: "Amenity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Add payment methods to an amenity
  def add_payment_methods
    sanitized_methods = params[:payment_methods].reject(&:blank?) # Remove empty strings
    if @amenity.add_payment_methods(sanitized_methods)
      redirect_to @amenity, notice: "Payment methods were successfully added."
    else
      redirect_to @amenity, alert: "Failed to add payment methods."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_amenity
    @amenity = Amenity.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def amenity_params
    params.require(:amenity).permit(:site_id, :fac_type,
                                    :is_member_adult,
                                    :is_member_child,
                                    :is_guest_adult,
                                    :is_guest_child,
                                    :is_tenant_child,
                                    :is_tenant_adult, :type_of_facility, :fac_name, :member_charges, :book_before, :is_hotel, :no_of_days, :disclaimer,:tenant, :cancellation_policy, :cutoff_min, :return_percentage, :create_by, :active, :member_price_adult, :member_price_child, :guest_price_adult, :guest_price_child, :min_people, :max_people, :cancel_before, :terms, :deposit, :description, :max_slots, :member,:guest,:gst_no, :advance_booking, :book_by, :tenant_price_child, :non_member, :non_member_price_adult, :non_member_price_child, :fixed_amount, :is_fixed, :complimentary, :postpaid, :prepaid, :gst, :consecutive_slot_allowed,:tenant_price_adult,:pay_on_facility,:sgst,:status,payment_methods: [],
                                    amenity_slots_attributes: [:id,:amenity_id,:start_hr, :end_hr,:start_min,:end_min],
                                    amenity_booking_rules_attributes: [:id, :enumerator, :duration, :level, :active, :amenity_id, :site_id, :facility_can_be_booked, :times_per_day, :period_type, prime_times_attributes: [:id, :amenity_booking_rules_id, :start_time, :end_time] ],
                                    amenity_operational_days_attributes: [
                                      :id,
                                      :amenity_id,
                                      :day_of_week,
                                      :start_time,
                                      :end_time,
                                      :is_active,
                                      :_destroy
                                    ]
                                    )
  end


  # Generate XLSX data for amenities
  def generate_xlsx(amenities)
    require 'caxlsx'

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Amenities') do |sheet|
      # Header row with styling
      header_style = workbook.styles.add_style(
        bg_color: '4472C4',
        fg_color: 'FFFFFF',
        alignment: { horizontal: :center, vertical: :center },
        font: { bold: true }
      )

      headers = ['ID', 'Name', 'Facility Type', 'Description', 'Member Price (Adult)',
                 'Member Price (Child)', 'Guest Price (Adult)', 'Guest Price (Child)',
                 'Non-Member Adult', 'Non-Member Child', 'Tenant Adult', 'Tenant Child',
                 'Max People', 'Min People', 'Booking Before (Days)', 'Advance Booking',
                 'Cancellation Policy', 'Cancel Before', 'Return %', 'Payment Methods', 'Status', 'Created At']

      sheet.add_row headers, style: header_style

      # Data rows
      amenities.each do |amenity|
        sheet.add_row [
          amenity.id,
          amenity.fac_name,
          amenity.type_of_facility,
          amenity.description,
          amenity.member_price_adult,
          amenity.member_price_child,
          amenity.guest_price_adult,
          amenity.guest_price_child,
          amenity.non_member_price_adult,
          amenity.non_member_price_child,
          amenity.tenant_price_adult,
          amenity.tenant_price_child,
          amenity.max_people,
          amenity.min_people,
          amenity.book_before,
          amenity.advance_booking,
          amenity.cancellation_policy,
          amenity.cancel_before,
          amenity.return_percentage,
          amenity.payment_methods&.join(', '),
          amenity.status,
          amenity.created_at&.strftime('%Y-%m-%d %H:%M:%S')
        ]
      end

      # Auto-fit columns
      sheet.column_widths 8, 20, 15, 20, 15, 15, 15, 15, 15, 15, 15, 15, 12, 12, 15, 15, 20, 12, 10, 20, 12, 18
    end

    package.to_stream.read
  end

  # Format amenity data for JSON export
  def amenity_export_json(amenity)
    {
      id: amenity.id,
      name: amenity.fac_name,
      facility_type: amenity.type_of_facility,
      description: amenity.description,
      pricing: {
        member_adult: amenity.member_price_adult,
        member_child: amenity.member_price_child,
        guest_adult: amenity.guest_price_adult,
        guest_child: amenity.guest_price_child,
        non_member_adult: amenity.non_member_price_adult,
        non_member_child: amenity.non_member_price_child,
        tenant_adult: amenity.tenant_price_adult,
        tenant_child: amenity.tenant_price_child
      },
      capacity: {
        min_people: amenity.min_people,
        max_people: amenity.max_people
      },
      booking_rules: {
        book_before_days: amenity.book_before,
        advance_booking: amenity.advance_booking,
        cancellation_policy: amenity.cancellation_policy,
        cancel_before: amenity.cancel_before,
        return_percentage: amenity.return_percentage,
        consecutive_slot_allowed: amenity.consecutive_slot_allowed
      },
      payment_methods: amenity.payment_methods,
      status: amenity.status,
      created_at: amenity.created_at,
      updated_at: amenity.updated_at
    }
  end

  # Sanitize payment methods to remove empty strings
  def sanitized_amenity_params
    params_with_sanitized_methods = amenity_params.dup
    params_with_sanitized_methods[:payment_methods] = amenity_params[:payment_methods]&.reject(&:blank?)
    params_with_sanitized_methods
  end
end
