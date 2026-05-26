class AttendancesController < ApplicationController

  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_attendance, only: %i[show edit update destroy]
  #before_action :set_attendance, only: %i[face_check_in face_check_out]

  # GET /attendances or /attendances.json
  def index
    @sites = @user.sites
    @users = User.where(
      id: UserSite.where(site_id: @user.current_site_id).pluck(:user_id),
      user_type: ["pms_technician", "pms_admin"]
    )
    @attendances = Attendance.where(resource_id: @user.current_site_id, resource_type: "Site")
    if params[:q]&.dig(:attendance_of_id).present?
      @attendances = @attendances.where(attendance_of_id: params[:q][:attendance_of_id])
    elsif !['pms_admin', 'security_guard'].include?(@user.user_type)
      @attendances = @attendances.where(attendance_of_id: @user.id)
    end
    # Use the correct association name here
    @attendances = @attendances.includes(:attendance_of, staff: [:profile_picture])
    @attendances = @attendances.ransack(params[:q]).result
    @attendances_json = @attendances.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 10)
    respond_to do |format|
      format.json { render 'index', status: :ok }
    end
  end

  # GET /attendances/1 or /attendances/1.json
  def show
  end

  def status_count
    # binding.pry
    site_id = params[:site_ids].present? ? params[:site_ids].split(",") : @user.selected_site_id
    today_range = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

    @attendances = {}

    @attendances[:total_count] = Attendance.where(resource_id: site_id).count
    # @attendances[:total_today] = Attendance.where(resource_id: site_id, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
    @attendances[:todays_in] = Attendance.where(resource_id: site_id, punched_in_at: today_range).count
    @attendances[:todays_out] = Attendance.where(resource_id: site_id, punched_out_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
    render json: @attendances
  end


  def attendances_report
    @users = User.where(id: UserSite.where(site_id: @user.current_site_id).pluck(:user_id), user_type: ["pms_technician", "pms_admin"])
  end

  # GET /attendances/new
  def new
    @attendance = Attendance.new
  end

  # GET /attendances/1/edit
  def edit
  end

  def users
    @att_user = User.find(params[:user_id])
    render :show
    # @attendances = Attendance.where(user_id: params[:user_id])
  end

  def face_check_in
    unless params[:image].present?
      return render json: { error: "Image is required" }, status: :bad_request
    end
    begin
      result = FaceAiService.analyze(params[:image].path)
    rescue StandardError => e
      Rails.logger.error "FaceAiService error: #{e.message}"
      return render json: { error: "Face AI service unavailable" }, status: :service_unavailable
    end
    unless result["success"]
      return render json: { error: result["error"] || "Face detection failed" }, status: :unprocessable_entity
    end
    embedding = result["embedding"]
    # Scope to current site for better performance
    site_id = params[:site_id] || @user&.current_site_id
    vs = site_id.present? ? Staff.where(site_id: site_id) : Staff.all
    visitors_with_embedding = vs.where.not(embedding: [nil, ""])
    bm = nil
    bs = 0.0
    # binding.pry
    visitors_with_embedding.find_each do |visitor|
      begin
        stored_embedding = JSON.parse(visitor.embedding)
        score = cosine_similarity(embedding, stored_embedding)

        if score > bs
          bs = score
          bm = visitor
        end
      rescue JSON::ParserError
        Rails.logger.warn "Invalid embedding JSON for visitor #{visitor.id}"
        next
      end
    end
    if bs > 0.75
      tin = bm.attendances.where(resource_id: site_id).where(punched_in_at: Time.current.beginning_of_day..Time.current.end_of_day).where(punched_out_at: nil).exists?
      # binding.pry
      if tin
        return render json: {
          message: "Staff is already marked IN. Please check OUT first."
        }, status: :unprocessable_entity
      end
      visitor_visit = bm.attendances.create!(punched_in_at: Time.current, attendance_of_type: params[:type_of], resource_type: "Site", resource_id: params[:site_id])
      bm.update(staff_in_out: 'IN')
      render json: {
        matched: true,
        staff_id: bm.id,
        staff_name: bm.full_name,
        confidence: bs.round(3),
        attendance_id: visitor_visit.id,
        check_in: visitor_visit.punched_in_at
      }, status: :created
    else
      render json: {
        matched: false,
        bs: bs.round(3),
        message: "No matching Staff found with sufficient confidence"
      }, status: :not_found
    end
  end

  def face_check_out
    unless params[:image].present?
      return render json: { error: "Image is required" }, status: :bad_request
    end

    begin
      result = FaceAiService.analyze(params[:image].path)
    rescue StandardError => e
      Rails.logger.error "FaceAiService error: #{e.message}"
      return render json: { error: "Face AI service unavailable" }, status: :service_unavailable
    end

    unless result["success"]
      return render json: { error: result["error"] || "Face detection failed" }, status: :unprocessable_entity
    end
    embedding = result["embedding"]
    # Scope to visitors currently IN
    site_id =  params[:site_id] || @user&.current_site_id
    vs = site_id.present? ? Staff.where(site_id: site_id) : Staff.all
    visitors_in = vs.where(staff_in_out: 'IN').where.not(embedding: [nil, ""])

    bm = nil
    bs = 0.0

    visitors_in.find_each do |visitor|
      begin
        stored_embedding = JSON.parse(visitor.embedding)
        score = cosine_similarity(embedding, stored_embedding)

        if score > bs
          bs = score
          bm = visitor
        end
      rescue JSON::ParserError
        next
      end
    end

    if bs > 0.70
      active_visit = bm.attendances.where(punched_out_at: nil).last

      if active_visit
        active_visit.update!(punched_out_at: Time.current, attendance_of_type: params[:type_of], resource_type: "Site", resource_id: params[:site_id])
        bm.update(staff_in_out: 'OUT')

        render json: {
          matched: true,
          staff_id: bm.id,
          staff_name: bm&.full_name,
          confidence: bs.round(3),
          attendance_id: active_visit.id,
          check_in: active_visit.punched_in_at,
          check_out: active_visit.punched_out_at
        }, status: :ok
      else
        render json: {
          error: "Staff found but no active check-in exists",
          staff_id: bm.id
        }, status: :unprocessable_entity
      end
    else
      render json: {
        matched: false,
        bs: bs.round(3),
        message: "No matching visitor found with sufficient confidence"
      }, status: :not_found
    end
  end

  def face_check_in_out
    unless params[:image].present?
      return render json: { error: "Image is required" }, status: :bad_request
    end

    begin
      result = FaceAiService.analyze(params[:image].path)
    rescue StandardError => e
      Rails.logger.error "FaceAiService error: #{e.message}"
      return render json: { error: "Face AI service unavailable" }, status: :service_unavailable
    end

    unless result["success"]
      return render json: { error: result["error"] || "Face detection failed" }, status: :unprocessable_entity
    end

    embedding = result["embedding"]
    site_id = params[:site_id] || @user&.current_site_id
    vs = site_id.present? ? Staff.where(site_id: site_id) : Staff.all
    staff_with_embedding = vs.where.not(embedding: [nil, ""])
    bm = nil
    bs = 0.0
    # Find best matching staff member
    staff_with_embedding.find_each do |staff|
      begin
        stored_embedding = JSON.parse(staff.embedding)
        score = cosine_similarity(embedding, stored_embedding)
        if score > bs
          bs = score
          bm = staff
        end
      rescue JSON::ParserError
        Rails.logger.warn "Invalid embedding JSON for staff #{staff.id}"
        next
      end
    end

    # Determine action based on staff's current status
    if bm.nil?
      return render json: {
        matched: false,
        bs: 0.0,
        message: "No matching staff found"
      }, status: :not_found
    end

    # Check if staff is currently IN
    is_staff_in = bm.staff_in_out == 'IN'

    if is_staff_in
      # CHECKOUT LOGIC
      if bs > 0.70
        active_visit = bm.attendances.where(punched_out_at: nil).last

        if active_visit
          active_visit.update!(punched_out_at: Time.current, attendance_of_type: params[:type_of], resource_type: "Site", resource_id: params[:site_id])
          bm.update(staff_in_out: 'OUT')

          render json: {
            action: "check_out",
            matched: true,
            staff_id: bm.id,
            staff_name: bm.full_name,
            confidence: bs.round(3),
            attendance_id: active_visit.id,
            check_in: active_visit.punched_in_at,
            check_out: active_visit.punched_out_at
          }, status: :ok
        else
          render json: {
            action: "check_out",
            error: "Staff found but no active check-in exists",
            staff_id: bm.id
          }, status: :unprocessable_entity
        end
      else
        render json: {
          action: "check_out",
          matched: false,
          bs: bs.round(3),
          message: "Confidence too low for checkout"
        }, status: :not_found
      end
    else
      # CHECKIN LOGIC
      if bs > 0.80
        tin = bm.attendances.where(resource_id: site_id).where(punched_in_at: Time.current.beginning_of_day..Time.current.end_of_day).where(punched_out_at: nil).exists?
        if tin
          return render json: {
            action: "check_in",
            message: "Staff is already marked IN. Please check OUT first."
          }, status: :unprocessable_entity
        end
        visitor_visit = bm.attendances.create!(punched_in_at: Time.current, attendance_of_type: params[:type_of], resource_type: "Site", resource_id: params[:site_id])
        bm.update(staff_in_out: 'IN')
        render json: {
          action: "check_in",
          matched: true,
          staff_id: bm.id,
          staff_name: bm.full_name,
          confidence: bs.round(3),
          attendance_id: visitor_visit.id,
          check_in: visitor_visit.punched_in_at
        }, status: :created
      else
        render json: {
          action: "check_in",
          matched: false,
          bs: bs.round(3),
          message: "No matching staff found with sufficient confidence"
        }, status: :not_found
      end
    end
  end

  # POST /attendances or /attendances.json
  def create
    @attendance = Attendance.new(attendance_params)

    respond_to do |format|
      if @attendance.save
        format.html { redirect_to @attendance, notice: "Attendance was successfully created." }
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: {
            errors: @attendance.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end


  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to @attendance, notice: "Attendance was successfully updated." }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1 or /attendances/1.json
  def destroy
    @attendance.destroy
    respond_to do |format|
      format.html { redirect_to attendances_url, notice: "Attendance was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def attendance_params
    params.require(:attendance).permit(:staff_id ,:attendance_of_id, :attendance_of_type, :resource_id, :resource_type, :punched_in_at, :punched_out_at, :work_log)
  end

  def cosine_similarity(vec1, vec2)
    return 0.0 if vec1.nil? || vec2.nil? || vec1.empty? || vec2.empty?

    dot_product = vec1.zip(vec2).map { |a, b| a * b }.sum
    magnitude1 = Math.sqrt(vec1.map { |x| x**2 }.sum)
    magnitude2 = Math.sqrt(vec2.map { |x| x**2 }.sum)

    return 0.0 if magnitude1.zero? || magnitude2.zero?

    dot_product / (magnitude1 * magnitude2)
  end
end
