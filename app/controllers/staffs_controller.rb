class StaffsController < ApplicationController
  require 'rqrcode'
  require 'prawn'
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_staff, only: %i[ show edit update destroy ]

  # GET /staffs or /staffs.json
  def index
    base_query = Staff.where(site_id: @user.current_site_id).left_joins(:user, :vendor, :units).includes(:site,:profile_picture,:qr_code_image,:attendances,
                                                                                                         :vendor,:user,units: [:building, :floor])
    @q = base_query.ransack(params[:q])
    @staffs = @q
    .result(distinct: true)
    .order(created_at: :desc)
    .paginate(page: params[:page], per_page: params[:per_page] || 1000)
    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  def aniket_master
    @q = Staff.where(site_id: @user.current_site_id, created_by_id: @user.id).ransack(params[:q])
    # binding.pry
    @staffs = @q.result.includes(:site,:profile_picture,:qr_code_image,:attendances,:vendor,:user,units: [:building, :floor]).order(created_at: :desc).paginate(page: params[:page], per_page: params[:per_page] || 1000)
    respond_to do |format|
      format.html {}
      format.json { render 'created_by' , status: :ok }
      format.js {}
    end
  end

  # GET /staffs/punched_in_today
  def punched_in_today
    # Get staff who have punched in today but not punched out
    base_query = Staff.joins(:attendances).includes(:site,:profile_picture,:qr_code_image,:attendances,:vendor,:user,units: [:building, :floor])
    .where(site_id: @user.current_site_id)
    .where('DATE(attendances.punched_in_at) = ?', Date.current)
    .where('attendances.punched_out_at IS NULL')
    @q = base_query.ransack(params[:q])
    @staffs = @q.result
    .distinct
    .includes(:attendances, :units, :vendor, :profile_picture)
    .order('attendances.punched_in_at DESC')
    .paginate(page: params[:page], per_page: params[:per_page] || 1000)
    respond_to do |format|
      format.html { render :index }
      format.json { render :punched_in_today }
    end
  end

  # GET /staffs/punched_out_today
  def punched_out_today
    # Get staff who have punched in and out today (completed their day)
    base_query = Staff.joins(:attendances).includes(:site,:profile_picture,:qr_code_image,:attendances,:vendor,:user,units: [:building, :floor])
    .where(site_id: @user.current_site_id)
    .where('DATE(attendances.punched_in_at) = ?', Date.current)
    .where('attendances.punched_out_at IS NOT NULL')
    @q = base_query.ransack(params[:q])
    @staffs = @q.result
    .distinct
    .includes(:attendances, :units, :vendor, :profile_picture)
    .order('attendances.punched_out_at DESC')
    .paginate(page: params[:page], per_page: params[:per_page] || 1000)

    respond_to do |format|
      format.html { render :index }
      format.json { render :punched_out_today }
    end
  end

  # GET /staffs/1 or /staffs/1.json
  def show
    @filtered_working_schedule = @staff.filtered_working_schedule
  end



  def get_staffs_count
    # binding.pry
    site_id = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    # site_id = @user.current_site_id
    @total_staffs = Staff.where(site_id: site_id).count
    # @total_in = Staff.where(site_id: site_id).joins(:attendances).where("attendances.punched_in_at IS NOT NULL AND attendances.punched_out_at IS NULL").count
    @total_in = Staff
    .where(site_id: site_id)
    .joins(:attendances)
    .where("attendances.punched_in_at IS NOT NULL AND attendances.punched_out_at IS NULL")
    .distinct
    .count
    #@total_out = Staff.where(site_id: site_id).joins(:attendances).where("attendances.punched_out_at IS NOT NULL AND attendances.punched_in_at IS NOT NULL").count
    @total_out = Staff
    .where(site_id: site_id)
    .joins(:attendances)
    .where("attendances.punched_in_at IS NOT NULL AND attendances.punched_out_at IS NOT NULL")
    .distinct
    .count
    #@todays_in = Staff.where(site_id: site_id).joins(:attendances).where(attendances: {punched_in_at: Time.zone.today.all_day}).where(attendances: {punched_out_at: nil}).count
    @todays_in = Staff
    .where(site_id: site_id)
    .joins(:attendances)
    .where(attendances: { punched_in_at: Time.zone.today.all_day, punched_out_at: nil })
    .distinct
    .count
    #@todays_out = Staff.where(site_id: site_id).joins(:attendances).where.not(attendances: { punched_in_at: nil }).where(attendances:  {punched_out_at: Time.zone.today.all_day}).count
    @todays_out = Staff
    .where(site_id: site_id)
    .joins(:attendances)
    .where.not(attendances: { punched_in_at: nil })
    .where(attendances: { punched_out_at: Time.zone.today.all_day })
    .distinct
    .count

    render json: {
      m: "Staffs Count",
      total_count: @total_staffs,
      total_staff_in: @total_in,
      total_staff_out: @total_out,
      todays_in: @todays_in,
      todays_out: @todays_out
    }
  end

  # GET /staffs/new
  def new
    @staff = Staff.new
    @staff.initialize_working_schedule
  end


  def export_staffs
    # Date filtering
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_month

    @start_date = start_date
    @end_date = end_date

    # Get all staff for the site with their attendances in date range
    @staffs = Staff.where(site_id: @user.current_site_id)
    .includes(:vendor, :units, :profile_picture, attendances: [])
    .order(:firstname, :lastname)

    # Prepare attendance data for export
    @attendance_data = @staffs.map do |staff|
      attendances = staff.attendances
      .where("DATE(punched_in_at) BETWEEN ? AND ?", start_date, end_date)
      .order(punched_in_at: :asc)
      {
        staff: staff,
        attendances: attendances
      }
    end

    respond_to do |format|
      format.json do
        render json: @attendance_data.map { |data|
          {
            staff_id: data[:staff].id,
            staff_name: data[:staff].full_name,
            attendances: data[:attendances].map { |a|
              {
                id: a.id,
                date: a.punched_in_at&.to_date,
                punched_in_at: a.punched_in_at,
                punched_out_at: a.punched_out_at,
                status: a.punched_out_at.nil? ? "IN" : "OUT"
              }
            }
          }
        }
      end
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename=\"staff_attendance_#{start_date}_to_#{end_date}.xlsx\""
        render xlsx: 'export_staffs', filename: "staff_attendance_#{start_date}_to_#{end_date}.xlsx"
      end
    end
  end

  def qr_codes_download
    staffs = Staff.where(id: params[:staff_ids])
    pdf = Prawn::Document.new(page_size: 'A4')
    staffs.each do |staff|
      data = staff.qr_code_image.to_s
      next if data.blank?
      qr = RQRCode::QRCode.new(data)
      png = qr.as_png(
        bit_depth: 1,
        border_modules: 4,
        size: 300
      )
      pdf.text "Staff ID: #{staff.id}", size: 14
      pdf.text "Staff Name: #{staff.firstname} #{staff.lastname}", size: 14
      pdf.move_down 10
      pdf.image StringIO.new(png.to_s), width: 150
      pdf.move_down 30
    end
    send_data pdf.render,
      filename: "staff_qr_codes.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end


  # GET /staffs/1/edit
  def edit
    @staff.initialize_working_schedule
  end

  # POST /staffs or /staffs.json
  def create
    # binding.pry
    # @staff = Staff.new(staff_params.merge(site_id: @user.current_site_id))
    @staff = Staff.new(staff_params.merge(site_id: @user.current_site_id, created_by_id: @user.id))
    @staff.creator_user_type = @user.user_type
    respond_to do |format|
      if @staff.save
        # binding.pry
        if params[:staff][:profile_picture].present?
          profile_picture = Attachfile.create(
            image: params[:staff][:profile_picture],
            relation: "StaffProfilePicture",
            relation_id: @staff.id,
            active: 1
          )
        end

        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "StaffDocument", relation_id: @staff.id, active: 1)
          end
        end

        if defined?(profile_picture) && profile_picture&.image&.path.present?
          GenerateStaffEmbeddingJobJob.perform_later(@staff.id, profile_picture.image.path)
        end
        format.html { redirect_to @staff, notice: "Staff was successfully created." }
        format.json { render :show, status: :created, location: @staff }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @staff.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staffs/1 or /staffs/1.json
  def update
    respond_to do |format|
      if @staff.update(staff_params)
        if params[:staff][:profile_picture].present?
          @staff.profile_picture&.destroy
          profile_picture = Attachfile.create!(
            image: params[:staff][:profile_picture],
            relation: "StaffProfilePicture",
            relation_id: @staff.id,
            active: 1
          )
          GenerateStaffEmbeddingJobJob.perform_later(@staff.id, profile_picture.image.path)
        end
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "StaffDocument", relation_id: @staff.id, active: 1)
          end
        end

        if params[:staff][:unit_ids].present?
          @staff.unit_ids = params[:staff][:unit_ids]
        end
        format.html { redirect_to @staff, notice: "Staff was successfully updated." }
        format.json { render :show, status: :ok, location: @staff }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @staff.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staffs/1 or /staffs/1.json
  def destroy
    @staff.destroy
    respond_to do |format|
      format.html { redirect_to staffs_url, notice: "Staff was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /staffs/staff_dashboard
  # Params: site_id, start_date, end_date, count_type, count_value, record_page
  def staff_dashboard
    site_id    = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    start_date = params[:start_date].presence&.to_date
    end_date   = params[:end_date].presence&.to_date
    date_range = staff_date_range(start_date, end_date)

    base_scope = Staff.where(site_id: site_id)
    date_scope = date_range ? base_scope.where(created_at: date_range) : base_scope

    count_type  = params[:count_type].to_s.presence
    count_value = params[:count_value].to_s.presence
    record_page = (params[:record_page].presence || 1).to_i

    today_range = Time.zone.today.all_day

    # ── Top-level counts ────────────────────────────────────────────────────────
    staff_ids = base_scope.pluck(:id)

    today_in_ids  = Attendance.where(attendance_of_type: "Staff", attendance_of_id: staff_ids)
    .where(punched_in_at: today_range, punched_out_at: nil)
    .distinct.pluck(:attendance_of_id)
    today_out_ids = Attendance.where(attendance_of_type: "Staff", attendance_of_id: staff_ids)
    .where.not(punched_in_at: nil)
    .where(punched_out_at: today_range)
    .distinct.pluck(:attendance_of_id)
    total_in_ids  = Attendance.where(attendance_of_type: "Staff", attendance_of_id: staff_ids)
    .where.not(punched_in_at: nil).where(punched_out_at: nil)
    .distinct.pluck(:attendance_of_id)
    total_out_ids = Attendance.where(attendance_of_type: "Staff", attendance_of_id: staff_ids)
    .where.not(punched_in_at: nil).where.not(punched_out_at: nil)
    .distinct.pluck(:attendance_of_id)

    result = {}
    result[:total]          = base_scope.count
    result[:in_date_range]  = date_scope.count
    result[:approved]       = base_scope.where(status_type: "Approved").count
    result[:pending]        = base_scope.where(status_type: "Pending").count
    result[:active]         = base_scope.where(status: true).count
    result[:inactive]       = base_scope.where(status: [false, nil]).count
    result[:today_in]       = today_in_ids.size
    result[:today_out]      = today_out_ids.size
    result[:total_in]       = total_in_ids.size
    result[:total_out]      = total_out_ids.size

    # ── by_work_type ────────────────────────────────────────────────────────────
    work_type_counts = date_scope
    .group("COALESCE(NULLIF(staffs.work_type,''), 'Unspecified')")
    .count
    result[:by_work_type] = build_staff_group(
      date_scope, 'work_type', work_type_counts,
      ->(scope, val) {
        val == 'Unspecified' ? scope.where("staffs.work_type IS NULL OR TRIM(staffs.work_type) = ''")
        : scope.where(work_type: val)
      },
      count_type, count_value, record_page
    )

    # ── by_vendor ────────────────────────────────────────────────────────────────
    vendor_counts = date_scope
    .joins("LEFT JOIN vendors ON vendors.id = staffs.vendor_id")
    .group("COALESCE(NULLIF(vendors.vendor_name,''), 'In-House')")
    .count
    result[:by_vendor] = build_staff_group(
      date_scope, 'vendor', vendor_counts,
      ->(scope, val) {
        if val == 'In-House'
          scope.where(vendor_id: nil)
        else
          scope.joins("LEFT JOIN vendors ON vendors.id = staffs.vendor_id")
          .where(vendors: { vendor_name: val })
        end
      },
      count_type, count_value, record_page
    )

    # ── by_status_type ───────────────────────────────────────────────────────────
    status_type_counts = date_scope
    .group("COALESCE(NULLIF(staffs.status_type,''), 'Pending')")
    .count
    result[:by_status_type] = build_staff_group(
      date_scope, 'status_type', status_type_counts,
      ->(scope, val) { scope.where(status_type: val) },
      count_type, count_value, record_page
    )

    # ── by_in_out (staff_in_out field) ──────────────────────────────────────────
    in_out_counts = date_scope
    .group("UPPER(COALESCE(NULLIF(staffs.staff_in_out,''), 'NOT_RECORDED'))")
    .count
    result[:by_in_out] = build_staff_group(
      date_scope, 'in_out', in_out_counts,
      ->(scope, val) {
        val == 'NOT_RECORDED' ? scope.where("staffs.staff_in_out IS NULL OR staffs.staff_in_out = ''")
        : scope.where("UPPER(staffs.staff_in_out) = ?", val)
      },
      count_type, count_value, record_page
    )

    # ── by_attendance_today ──────────────────────────────────────────────────────
    present_count = today_in_ids.size + today_out_ids.size
    absent_count  = base_scope.count - (today_in_ids | today_out_ids).size
    attendance_counts = { "Present" => present_count, "Absent" => [absent_count, 0].max }
    result[:by_attendance_today] = build_staff_group(
      base_scope, 'attendance_today', attendance_counts,
      ->(scope, val) {
        ids = val == "Present" ? (today_in_ids | today_out_ids) : scope.pluck(:id) - (today_in_ids | today_out_ids)
        scope.where(id: ids)
      },
      count_type, count_value, record_page
    )

    # ── by_created_by ────────────────────────────────────────────────────────────
    creator_counts = date_scope
    .joins("LEFT JOIN users AS cu ON cu.id = staffs.created_by_id")
    .group("TRIM(CONCAT(COALESCE(cu.firstname,''), ' ', COALESCE(cu.lastname,'')))")
    .count
    result[:by_created_by] = build_staff_group(
      date_scope, 'created_by', creator_counts,
      ->(scope, val) {
        scope.joins("LEFT JOIN users AS cu ON cu.id = staffs.created_by_id")
        .where("TRIM(CONCAT(COALESCE(cu.firstname,''), ' ', COALESCE(cu.lastname,''))) = ?", val)
      },
      count_type, count_value, record_page,
      key_transform: ->(k) { k.to_s.strip.presence || 'Unknown' }
    )

    render json: result
  end

  # GET /staffs/staff_drill
  # Params: site_id, filter_type, filter_value, start_date, end_date, page, per_page
  def staff_drill
    site_id      = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    filter_type  = params[:filter_type].to_s
    filter_value = params[:filter_value].to_s
    per_page     = [[(params[:per_page] || STAFF_PER_PAGE).to_i, 1].max, 200].min
    page         = [params[:page].to_i, 1].max

    start_date   = params[:start_date].presence&.to_date
    end_date     = params[:end_date].presence&.to_date
    date_range   = staff_date_range(start_date, end_date)

    scope = Staff.where(site_id: site_id)
    .includes(:vendor, :units, :profile_picture)

    scope = scope.where(created_at: date_range) if date_range

    today_range = Time.zone.today.all_day

    case filter_type
    when "work_type"
      if filter_value == "Unspecified"
        scope = scope.where("staffs.work_type IS NULL OR TRIM(staffs.work_type) = ''")
      else
        scope = scope.where(work_type: filter_value)
      end
    when "vendor"
      if filter_value == "In-House"
        scope = scope.where(vendor_id: nil)
      else
        scope = scope.joins("LEFT JOIN vendors ON vendors.id = staffs.vendor_id")
        .where(vendors: { vendor_name: filter_value })
      end
    when "status_type"
      scope = scope.where(status_type: filter_value)
    when "in_out"
      if filter_value == "NOT_RECORDED"
        scope = scope.where("staffs.staff_in_out IS NULL OR staffs.staff_in_out = ''")
      else
        scope = scope.where("UPPER(staffs.staff_in_out) = ?", filter_value.upcase)
      end
    when "attendance_today"
      staff_ids     = Staff.where(site_id: site_id).pluck(:id)
      present_ids   = Attendance.where(attendance_of_type: "Staff", attendance_of_id: staff_ids)
      .where(punched_in_at: today_range)
      .distinct.pluck(:attendance_of_id)
      if filter_value == "Present"
        scope = scope.where(id: present_ids)
      else
        scope = scope.where.not(id: present_ids)
      end
    when "created_by"
      scope = scope
      .joins("LEFT JOIN users AS cu ON cu.id = staffs.created_by_id")
      .where("TRIM(CONCAT(COALESCE(cu.firstname,''), ' ', COALESCE(cu.lastname,''))) = ?", filter_value)
    end

    paginated = scope.order(created_at: :desc).page(page).per(per_page)

    render json: {
      filter_type:  filter_type,
      filter_value: filter_value,
      count:        paginated.total_count,
      total_pages:  paginated.total_pages,
      current_page: paginated.current_page,
      per_page:     per_page,
      records:      paginated.map { |s| staff_record_details(s) }
    }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_staff
    @staff = Staff.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def staff_params
    params.require(:staff).permit(:site_id, :staff_in_out, :date_of_birth, :firstname, :created_by_id, :status_type ,:lastname, :email, :mobile_no, :work_type, :vendor_id, :valid_from, :valid_till, :longitude, :latitude, :status,  unit_ids: [], working_schedule: Date::DAYNAMES.map { |day| [day, [:selected, :start_time, :end_time]] }.to_h)
  end

  STAFF_PER_PAGE = 10

  def staff_record_details(s)
    last_attendance = s.attendances.order(punched_in_at: :desc).first
    {
      id:              s.id,
      staff_id:        s.staff_id,
      name:            s.full_name,
      email:           s.email,
      mobile_no:       s.mobile_no,
      work_type:       s.work_type,
      vendor:          s.vendor&.vendor_name || 'In-House',
      status_type:     s.status_type,
      staff_in_out:    s.staff_in_out,
      valid_from:      s.valid_from,
      valid_till:      s.valid_till,
      created_at:      s.created_at,
      last_punched_in:  last_attendance&.punched_in_at,
      last_punched_out: last_attendance&.punched_out_at
    }
  end

  def build_staff_group(base_scope, filter_type, counts_hash, scope_filter_proc,
                        count_type, count_value, record_page,
                        key_transform: ->(k) { k.to_s })
    result       = {}
    load_records = (count_type == filter_type)

    counts_hash.each do |key, count|
      display_key = key_transform.call(key)

      if load_records && count_value.present? && count_value == display_key
        filtered  = scope_filter_proc.call(base_scope, key)
        .includes(:vendor, :units, :profile_picture, :attendances)
        .order(created_at: :desc)
        .page(record_page).per(STAFF_PER_PAGE)
        result[display_key] = {
          count:        count,
          records:      filtered.map { |s| staff_record_details(s) },
          total_pages:  filtered.total_pages,
          current_page: filtered.current_page,
          per_page:     STAFF_PER_PAGE
        }
      else
        result[display_key] = count
      end
    end
    result
  end

  def staff_date_range(start_date, end_date)
    if start_date && end_date
      start_date.beginning_of_day..end_date.end_of_day
    elsif start_date
      start_date.beginning_of_day..start_date.end_of_day
    elsif end_date
      end_date.beginning_of_day..end_date.end_of_day
    end
  end
end
