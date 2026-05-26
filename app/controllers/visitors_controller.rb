class VisitorsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user, except: [:get_visitor_by_id, :scan_qr]
  before_action :api_user , except: [:get_visitor_by_id, :scan_qr]
  before_action :set_user, except: [:get_visitor_by_id, :scan_qr]
  before_action :load_visitor_data, only: [:new, :create, :edit, :update]
  before_action :set_visitor, only: %i[show edit update destroy verify_otp validate_otp resend_otp approve_visitor]
  skip_before_action :verify_authenticity_token, only: [:renotify_host]

  # GET /visitors or /visitors.json
  def index
    Visitor.update_expired_passes
    scope = Visitor.where(site_id: @user.current_site_id).where.not(is_deleted: true).joins(:created_by)

    # Track if we need distinct (to avoid N+1 with includes)
    needs_distinct = false

    # Filter by building_id
    if params[:building_id].present?
      scope = scope.joins(hosts: { user: { user_sites: { unit: :building } } })
      .where(units: { building_id: params[:building_id] })
      needs_distinct = true
    end

    # Filter by floor_id
    if params[:floor_id].present?
      scope = scope.joins(hosts: { user: { user_sites: { unit: :floor } } })
      .where(units: { floor_id: params[:floor_id] })
      needs_distinct = true
    end

    # Filter by unit_id
    if params[:unit_id].present?
      scope = scope.joins(hosts: { user: { user_sites: :unit } })
      .where(user_sites: { unit_id: params[:unit_id] })
      needs_distinct = true
    end

    # Filter by host_id
    if params[:host_id].present?
      scope = scope.joins(:hosts).where(hosts: { user_id: params[:host_id] })
      needs_distinct = true
    end

    if params[:q].present?
      q_params = params[:q].to_unsafe_h rescue params[:q]
      us_filters = {}
      %w[build_id floor_id unit_id].each do |col|
        key = "hosts_user_user_sites_#{col}_eq"
        us_filters[col.to_sym] = q_params[key] if q_params[key].present?
      end
      if us_filters.any?
        needs_distinct = true
      end
    end

    @q = scope.ransack(params[:q])

    # Use select with distinct to avoid issues with includes
    visitor_ids = @q.result.distinct.pluck(:id) if needs_distinct

    @visitors = if needs_distinct
      Visitor.where(id: visitor_ids).joins(:created_by)
      .includes(:extra_visitors, :profile_pic, :visitor_files, :visitor_license, :visitor_consignment, :created_by, :visitor_visits, :hosts)
      .order(created_at: :desc)
      .page(params[:page])
      .per(params[:per_page] || 250)
    else
      @q.result.joins(:created_by)
      .includes(:extra_visitors, :profile_pic, :visitor_files, :visitor_license, :visitor_consignment, :created_by, :visitor_visits, :hosts)
      .order(created_at: :desc)
      .page(params[:page])
      .per(params[:per_page] || 250)
    end
    render :index
  end


  def get_visitr_list
    visitors = Visitor.where(site_id: @user.current_site_id)
    .yield_self do |scope|
      if %w[pms_admin security_guard].include?(@user.user_type)
        scope
      else
        scope.where(created_by_id: @user.id)
      end
    end
    .select(:id, :name) # only fetch id and name for speed

    render json: visitors
  end

  def get_visitor
    search_param = params[:mobile] || params[:vehicle_number]
    search_column = params[:mobile].present? ? :contact_no : :vehicle_number
    if search_param.present?
      @visitor = Visitor.find_by(search_column => search_param)
      if @visitor
        fields = [:id, :name, search_column]
        render json: @visitor.as_json(only: fields), status: :ok
      else
        render json: { message: "Visitor not available." }, status: :not_found
      end
    else
      render json: { message: "Mobile number or Vehicle number is required." }, status: :bad_request
    end
  end

  def visitor_category
    categories = Visitor.group(:visit_type).count

    @categories = categories.map do |name, count|
      { name: name.to_s.strip.capitalize, count: count }
    end

    respond_to do |format|
      format.json {render 'generic_infos/visitor_category'}
    end
  end


  def get_visitor_by_id
    if params[:id].present?
      @visitor = Visitor.find_by(id: params[:id])
      if @visitor
        respond_to do |format|
          format.html {render plain: "To Kaise Ho Aap!" , status: :ok}
          format.json {render 'visitor_link', status: :ok}
        end
      else
        render json: { message: "Visitor not available by this ID." }, status: :not_found
      end
    else
      render json: { message: "Visitor ID is required." }, status: :bad_request
    end
  end

  # Gate QR scan endpoint (secure token + id)
  # Expects params: v (visitor_id) and t (token)
  # - If not checked-in, must be scanned within qr_pending_expiry_minutes
  # - If checked-in, valid up to 1 day from qr_generated_at

  def scan_qr
    visitor_id = params[:v].presence || params[:visitor_id]
    token = params[:t]

    unless visitor_id.present? && token.present?
      render json: { error: 'v (visitor_id) and t (token) are required' }, status: :bad_request and return
    end

    visitor = Visitor.find_by(id: visitor_id)
    unless visitor
      render json: { error: 'Visitor not found' }, status: :not_found and return
    end

    # Parse check_in time from params (use this for all validations)
    check_in_time = params[:check_in].present? ? Time.zone.parse(params[:check_in]) : Time.current

    # Parse check_out time from params if present
    check_out_time = params[:check_out].present? ? Time.zone.parse(params[:check_out]) : Time.current

    # Debug: log validation details
    Rails.logger.info "scan_qr: visitor_id=#{visitor_id}, token=#{token}, check_in_time=#{check_in_time}"
    Rails.logger.info "scan_qr: qr_token_valid?=#{visitor.qr_token_valid?(token)}, qr_generated_at=#{visitor.qr_generated_at}, qr_pending_expiry_minutes=#{visitor.qr_pending_expiry_minutes}"

    unless visitor.qr_token_valid?(token)
      render json: { error: 'Invalid QR token', visitor_id: visitor.id }, status: :unauthorized and return
    end

    # Calculate expiry times
    qr_valid_from = visitor.qr_expiry_base_time
    qr_expires_at = visitor.qr_expires_at

    # Handle check_out request
    if params[:check_out].present?
      active_visit = visitor.visitor_visits.where(check_out: nil).where.not(check_in: nil).last
      if active_visit
        active_visit.update(check_out: check_out_time)
        visitor.update(visitor_in_out: 'OUT')
        render json: {
          message: 'Visitor checked out successfully',
          visitor_id: visitor.id,
          visit_id: active_visit.id,
          visitor_in_out: 'OUT',
          check_in: active_visit.check_in,
          check_out: active_visit.check_out
        }, status: :ok and return
      else
        render json: { error: 'No active visit found to check out' }, status: :not_found and return
      end
    end

    # Handle check_in request
    # First check if check_in_time is BEFORE the valid window starts
    if visitor.qr_not_yet_valid?(at_time: check_in_time)
      render json: {
        error: 'QR not yet valid',
        message: "QR is valid from #{qr_valid_from&.strftime('%d %b %Y %I:%M %p')} to #{qr_expires_at&.strftime('%d %b %Y %I:%M %p')}",
        visitor_id: visitor.id,
        qr_valid_from: qr_valid_from,
        qr_expires_at: qr_expires_at,
        check_in_time: check_in_time
      }, status: :unauthorized and return
    end

    # Check if QR has expired
    if visitor.qr_expired?(at_time: check_in_time)
      render json: {
        error: 'QR expired',
        message: "QR was valid from #{qr_valid_from&.strftime('%d %b %Y %I:%M %p')} to #{qr_expires_at&.strftime('%d %b %Y %I:%M %p')}",
        visitor_id: visitor.id,
        qr_valid_from: qr_valid_from,
        qr_expires_at: qr_expires_at,
        check_in_time: check_in_time
      }, status: :unauthorized and return
    end

    # Check if QR was already used for check-in
    if visitor.qr_checked_in_at.present?
      render json: {
        error: 'QR already used for check in. Check Out and create visitor again.',
        visitor_id: visitor.id,
        qr_checked_in_at: visitor.qr_checked_in_at
      }, status: :conflict and return
    end

    # Calculate remaining time for expiry message
    remaining_minutes = ((qr_expires_at - check_in_time) / 60).round
    remaining_minutes = 0 if remaining_minutes < 0
    expiry_message = if remaining_minutes > 0
      "QR will expire within #{remaining_minutes} minute#{'s' if remaining_minutes != 1}"
    else
      "QR has expired"
    end

    # Check for pending visit (check_in nil, check_out nil) and update it
    pending_visit = visitor.visitor_visits.where(check_in: nil, check_out: nil).last

    if pending_visit
      pending_visit.update(check_in: check_in_time)
      visitor.update(visitor_in_out: 'IN')
      visitor.mark_qr_checked_in!(check_in_time)
      render json: {
        message: 'Visitor checked in successfully',
        visitor_id: visitor.id,
        visit_id: pending_visit.id,
        visitor_in_out: 'IN',
        check_in: pending_visit.check_in,
        qr_checked_in_at: visitor.reload.qr_checked_in_at,
        qr_expires_at: qr_expires_at,
        qr_expiry_message: expiry_message
      }, status: :created and return
    end

    # Create new visit with check_in_time
    visitor_visit = visitor.visitor_visits.new(check_in: check_in_time)
    if visitor_visit.save
      visitor.update(visitor_in_out: 'IN')
      visitor.mark_qr_checked_in!(check_in_time)
      render json: {
        message: 'Visitor checked in successfully',
        visitor_id: visitor.id,
        visit_id: visitor_visit.id,
        visitor_in_out: 'IN',
        check_in: visitor_visit.check_in,
        qr_checked_in_at: visitor.reload.qr_checked_in_at,
        qr_expires_at: qr_expires_at,
        qr_expiry_message: expiry_message
      }, status: :created
    else
      render json: { errors: visitor_visit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def visitor_qr_codes
    @visitors = Visitor.where(site_id: @user.current_site_id) # Adjust the query as needed

    render pdf: 'visitor_qr_codes',
      disposition: 'attachment',
      dpi: 72,
      template: 'visitors/qr_codes.html',
      formats: :pdf,
      encoding: 'utf8'
  end

  # GET /visitors/1 or /visitors/1.json
  def show
    @visitor = Visitor.includes(:hosts, :extra_visitors, :visitor_visits, :profile_pic, :goods_in_out)
    .find(params[:id])
    @created_by_user = User.find_by(id: @visitor.created_by_id)
    @visitor_staff_category = GenericSubInfo.find_by(id: @visitor.visitor_staff_category_id)
    @parent = Visitor.find_by(id: @visitor.parent_id)
    @visitor_files = Attachfile.where(relation: 'VisitorFile', relation_id: @visitor.id)
  end

  # GET /visitors/new
  def new
    @visitor = Visitor.new
    @visitor.extra_visitors.build
  end

  # GET /visitors/1/edit
  def edit
    @visitor = Visitor.includes(:extra_visitors).find(params[:id])
  end

  def create
    # binding.pry
    @visitor = Visitor.new(visitor_params)
    @visitor.created_by_id ||= @user.id
    @visitor.site_id = @user.current_site_id

    if @visitor.save
      if params[:visitor][:visitor_files].present?
        params[:visitor][:visitor_files].each do |_, attachment|
          Attachfile.create!(
            image: attachment[:file],
            relation: "VisitorFile",
            relation_id: @visitor.id,
            category_type: attachment[:category_type],
            active: 1
          )
        end
      end
      if params[:visitor_consignment].present?
        params[:visitor_consignment].each do |doc|
          Attachfile.create!(
            image: doc,
            relation: "VisitorConsignment",
            relation_id: @visitor.id,
            active: 1
          )
        end
      end

      if params[:visitor_license].present?
        params[:visitor_license].each do |doc|
          Attachfile.create!(
            image: doc,
            relation: "VisitorLicense",
            relation_id: @visitor.id,
            active: 1
          )
        end
      end

      if params[:visitor][:profile_pic].present?
        profile_pic = Attachfile.create(
          image: params[:visitor][:profile_pic],
          relation: "VisitorProfilePic",
          relation_id: @visitor.id,
          active: 1
        )
      end

      # if profile_pic&.image&.path.present?
      #   result = FaceAiService.analyze(profile_pic.image.path)

      #   if result["success"]
      #     @visitor.update(embedding: result["embedding"].to_json)
      #   else
      #     Rails.logger.warn "Face AI failed: #{result["error"]}"
      #   end
      # end

      if params[:visitor][:profile_picture].present?
        profile_pic = Attachfile.create(
          image: params[:visitor][:profile_picture],
          relation: "VisitorProfilePic",
          relation_id: @visitor.id,    # Filter by building_id

          active: 1
        )
      end
      # if params[:visitor_files].present?
      #   params[:visitor_files].each do |doc|
      #   Attachfile.create(image: doc, relation: "VisitorFile", relation_id: @visitor.id, active: 1)
      #   end
      # end

      create_associated_records(@visitor)
      CreateVisitorJob.set(wait: 5.seconds).perform_later(@visitor.id, params[:visitor_files], request.host)

      # Enqueue notification job after all records are created
      if params[:visitor][:skip_host_approval] != true
        VisitorNotificationJob.perform_later(@visitor.id, 'create')
      end

      # Generate face embedding if profile picture was uploaded
      if defined?(profile_pic) && profile_pic&.image&.path.present?
        GenerateVisitorEmbeddingJob.perform_later(@visitor.id, profile_pic.image.path)
      end

      # Build response with QR expiry info if secure QR was generated
      response_data = @visitor.as_json(include: [:extra_visitors, :profile_pic])
      if @visitor.qr_pending_expiry_minutes.present?
        qr_expires_at = @visitor.qr_expires_at
        if qr_expires_at.present?
          remaining_seconds = qr_expires_at - Time.current
          if remaining_seconds > 0
            remaining_minutes = (remaining_seconds / 60).round
            response_data[:qr_expires_at] = qr_expires_at
            response_data[:qr_expiry_base_time] = @visitor.qr_expiry_base_time
            response_data[:qr_expiry_message] = "QR will expire within #{remaining_minutes} minute#{'s' if remaining_minutes != 1}"
          else
            response_data[:qr_expires_at] = qr_expires_at
            response_data[:qr_expiry_message] = "QR will be valid from #{@visitor.qr_expiry_base_time&.strftime('%d %b %I:%M %p')}"
          end
        end
      end

      render json: response_data, status: :created
    else
      render json: @visitor.errors, status: :unprocessable_entity
    end
  end
  def update
    if @visitor.update(visitor_params)
      # Profile picture
      # if params.dig(:visitor, :profile_picture).present?
      #   Attachfile.create!(
      #     image: params[:visitor][:profile_picture],
      #     relation: "VisitorProfilePic",
      #     relation_id: @visitor.id,
      #     active: 1
      #   )
      # end

      if params.dig(:visitor, :profile_picture).present?
        Attachfile.create!(
          image: params[:visitor][:profile_picture],
          relation: "VisitorProfilePic",
          relation_id: @visitor.id,
          active: 1
        )
      end

      # Visitor Consignment (single or multiple)
      Array(params[:visitor_consignment]).each do |doc|
        Attachfile.create!(
          image: doc,
          relation: "VisitorConsignment",
          relation_id: @visitor.id,
          active: 1
        )
      end if params[:visitor_consignment].present?

      # Visitor License (single or multiple)
      Array(params[:visitor_license]).each do |doc|
        Attachfile.create!(
          image: doc,
          relation: "VisitorLicense",
          relation_id: @visitor.id,
          active: 1
        )
      end if params[:visitor_license].present?

      render json: @visitor.as_json(include: [:extra_visitors, :profile_pic]), status: :ok
    else
      render json: @visitor.errors, status: :unprocessable_entity
    end
  end

  # DELETE /visitors/1 or /visitors/1.json
  def destroy
    @visitor.destroy
    respond_to do |format|
      format.html { redirect_to visitors_url, notice: "Visitor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def verify_votp
    visitor = Visitor.find_by(otp: params[:otp])

    if !visitor.present?
      render json: { error: "Invalid or expired OTP" }, status: :not_found and return
    end
    if visitor.verify_otp(params[:otp].to_i)
      @visitor_visit = VisitorVisit.find_by(visitor_id: visitor.id, created_at: Date.today,check_in: nil)
      if @visitor_visit.present?
        @visitor_visit.update(check_in: Time.current)
        visitor.update(visitor_in_out: "IN")
      else
        @visitor_visit = VisitorVisit.create(visitor_id: visitor.id, created_at: Date.today,check_in: nil)
        @visitor_visit.update(check_in: Time.current)
        visitor.update(visitor_in_out: "IN")
      end
      render json: { message: "OTP verified successfully.", vid: visitor.id, verified: visitor.verified}, status: :ok
    else
      render json: { error: "OTP verification failed" }, status: :unprocessable_entity
    end
  end

  # POST /visitors/1/resend_otp
  def resend_otp
    send_otp(@visitor)  # Resend OTP for the visitor
    flash[:notice] = "OTP has been resent."
    redirect_to verify_otp_visitor_path(@visitor)
  end

  def approve_visitor
    @visitor = Visitor.find(params[:id])
    @host = @visitor.hosts.find_by(user_id: @user.id)
    is_security = @user.user_type == "security_guard"
    unless @host || is_security
      respond_to do |format|
        format.html {redirect_to visitors_path, alert: "Your are not authorized to approve this visitor"}
        format.json { render json: {error: "Unauthorized"}, status: :unprocessable_entity }
      end
      return
    end
    approval = params[:approve] === "true"
    Visitor.transaction do
      if is_security
        @host  ||= @visitor.hosts.first
        @host.update!(
          is_approved: approval,
          approval_mode: params[:approval_mode],
          updated_at: Time.current
        )
      else
        (
          @host.update!(
            is_approved: approval,
            updated_at: Time.current
          )
        )
      end
      @visitor.update!(status: approval)
    end
    message = approval ? "Approved successfully" : "Approval Rejected successfully"
    respond_to do |format|
      format.html { redirect_to approval_form_visitors_path, notice: message }
      format.json { render json: {message: message}, status: :ok }
    end
  rescue =>  e
    Rails.logger.error "Approval error: #{e.message}"
    respond_to do |format|
      format.html { redirect_to approval_form_visitors_path, alert: 'Something went wrong during approval' }
      format.json { render json: { error: 'Something went wrong' }, status: :unprocessable_entity }
    end
  end


  #Old V
  # if @host
  #   approval = params[:approve] == 'true'
  #   mode_of_approval = params[:mode] unless params[:mode].present?
  #   # Ensure both records update in a transaction
  #   Visitor.transaction do
  #     @host.update!(is_approved: approval, approval_mode: mode_of_approval ,updated_at: Time.current)
  #     @visitor.update!(status: approval)
  #     # Gatekeeper notification is triggered by Host after_update callback
  #     # @host.notify_assigned_to if approval
  #   end
  #   message = approval ? 'Visitor approved successfully' : 'Visitor approval denied'
  #   respond_to do |format|
  #     format.html { redirect_to approval_form_visitors_path, notice: message }
  #     format.json { render json: { message: message }, status: :ok }
  #   end
  # else
  #   respond_to do |format|
  #     format.html { redirect_to visitors_path, alert: 'You are not authorized to approve this visitor' }
  #     format.json { render json: { error: 'You are not authorized to approve this visitor' }, status: :unauthorized }
  #   end
  # end
  # rescue => e
  #   Rails.logger.error "Approval error: #{e.message}"
  #   respond_to do |format|
  #     format.html { redirect_to approval_form_visitors_path, alert: 'Something went wrong during approval' }
  #     format.json { render json: { error: 'Something went wrong' }, status: :unprocessable_entity }
  #   end
  # end

  def self_registartions
    # binding.pry
    site_id = @user&.current_site_id
    @q = Visitor.ransack(params[:q])
    base_scope = @q.result.where( site_id: site_id, visit_type: "Guest-SelfRegistration").order(created_at: :desc)
    @self_reg = base_scope.page(params[:page]).per(params[:per_page] || 50)

    render json: {
      current_page: @self_reg.current_page,
      total_count: @self_reg.total_entries,
      total_pages: @self_reg.total_pages,
      data: @self_reg.map do |self_vsitor|
        {
          id: self_vsitor.id,
          visit_type: self_vsitor.visit_type,
          visitor_name: self_vsitor.try(:name),
          contact_no: self_vsitor.contact_no,
          purpose: self_vsitor.purpose,
          coming_from: self_vsitor.coming_from,
          hosts: self_vsitor&.hosts.map do |visitor_host|
            {
              host_id: visitor_host&.id,
              hosts_name: visitor_host&.user&.full_name,
            }
          end
        }
      end
    }
  end

  def approval_form
    visitors = Visitor.joins(:hosts)
    .where(hosts: { user_id: @user.id, is_approved: nil })
    .where(site_id: @user.current_site_id)
    .includes(:hosts)
    .order(created_at: :desc)
    .distinct

    page     = params[:page].to_i
    per_page = (params[:per_page] || 50).to_i
    @visitors_paginated = visitors.page(page).per(per_page)

    # Compute correct total_count even when .count returns a grouped hash
    relation_for_count = visitors.except(:limit, :offset, :order)
    count_result = relation_for_count.count
    total_count = count_result.respond_to?(:values) ? count_result.values.sum : count_result

    render json: {
      visitors: @visitors_paginated.map { |v|
        {
          id: v.id,
          name: v.name,
          contact: v.contact_no,
          purpose: v.purpose,
          expected_date: v.expected_date,
          expected_time: v.expected_time
        }
      },
      pagination: {
        total_pages: (@visitors_paginated.total_count.to_f / per_page).ceil, # or use @visitors_paginated.total_pages
        current_page: @visitors_paginated.current_page,
        total_count: total_count
      }
    }
  end

  def fetch_potential_hosts
    site_id = params[:site_id]
    @potential_hosts = User.where.not(user_type: 'security_guard')
    .where(current_site_id: site_id)
    .select(:id, :firstname, :lastname, :email, :current_site_id)
    .order(:firstname, :lastname)
    respond_to do |format|
      format.json do
        render json: {
          hosts: @potential_hosts.map do |user|
            {
              id: user.id,
              name: "#{user.firstname} #{user.lastname}",
              email: user.email,
              current_site_id: user.current_site_id
            }
          end
        }
      end
      format.html { render partial: 'host_options', locals: { hosts: @potential_hosts } }
    end
  end

  def get_host_approval
    @hosts = Host.includes(:visitor, :user).where(user_id: @user.id).order(created_at: :desc)
    if @hosts.any?
      host_approvals = @hosts.map do |host|
        {
          visitor_id: host.visitor.id,
          host_id: host.id,
          host_name: "#{host.user.firstname} #{host.user.lastname}",
          host_email: host.user.email,
          is_approved: host.is_approved,
          updated_at: host.updated_at,
          created_at: host.created_at
        }
      end
      render json: {
        user_id: @user.id,
        user_name: "#{@user.firstname} #{@user.lastname}",
        host_approvals: host_approvals
      }, status: :ok
    else
      render json: { error: 'No hosts found for this user' }, status: :not_found
    end
  end

  def approval_history
    visitors = Visitor
    .joins(:hosts)
    .where(hosts: { user_id: @user.id })
    .where.not(hosts: { is_approved: nil })
    .includes(:hosts, :extra_visitors, :created_by, :visitor_visits)
    .order('hosts.updated_at DESC')
    .page(params[:page])
    .per((params[:per_page] || 10).to_i)

    @approval_history = visitors.map do |visitor|
      host = visitor.hosts.find { |h| h.user_id == @user.id }

      # ✅ use loaded records (NO DB hit)
      visits = visitor.visitor_visits.sort_by(&:created_at).reverse

      check_in  = visits.first&.check_in
      check_out = visits.find { |v| v.check_out.present? }&.check_out

      {
        id: visitor.id,
        name: visitor.name,
        contact_no: visitor.contact_no,
        purpose: visitor.purpose,
        site_id: visitor.site_id,
        coming_from: visitor.coming_from,
        vehicle_number: visitor.vehicle_number,
        expected_date: visitor.expected_date,
        expected_time: visitor.expected_time,
        skip_host_approval: visitor.skip_host_approval,
        goods_inwards: visitor.goods_inwards,
        visit_type: visitor.visit_type,
        frequency: visitor.frequency,
        working_days: visitor.working_days,
        status: visitor.status,
        created_by_id: visitor.created_by_id,
        created_by_name: {
          firstname: visitor.created_by&.firstname,
          lastname: visitor.created_by&.lastname
        },
        start_pass: visitor.start_pass,
        end_pass: visitor.end_pass,
        pass_number: visitor.pass_number,
        created_at: visitor.created_at,
        updated_at: visitor.updated_at,
        extra_visitors: visitor.extra_visitors,
        approved: host&.is_approved,
        approved_by: host&.user&.full_name,
        approval_date: host&.updated_at,
        visitor_logs: {
          check_in: check_in,
          check_out: check_out
        }
      }
    end

    render json: {
      current_page: visitors.current_page,
      total_pages: visitors.total_pages,
      total_count: visitors.total_entries,
      approval_history: @approval_history
    }
  end

  def visitors_dashboard
    site_id    = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    start_date = params[:start_date].presence&.to_date
    end_date   = params[:end_date].presence&.to_date
    date_range = visitor_date_range(start_date, end_date)

    base_scope = Visitor.where(site_id: site_id).where(is_deleted: false)
    date_scope = date_range ? base_scope.where(created_at: date_range) : base_scope

    # Which group to drill into (nil = counts only)
    count_type  = params[:count_type].to_s.presence
    count_value = params[:count_value].to_s.presence
    record_page = (params[:record_page].presence || 1).to_i

    visitors = {}

    # ── Top-level counts ────────────────────────────────────────────────────────
    visitors[:total]        = base_scope.count
    visitors[:today]        = date_scope.count
    visitors[:expected_v]   = date_scope.joins(:created_by).where.not(users: { user_type: 'security_guard' }).count
    visitors[:unexpected_v] = date_scope.joins(:created_by).where(users: { user_type: 'security_guard' }).count
    visitors[:today_in]     = date_scope.where(visitor_in_out: %w[in IN]).count
    visitors[:today_out]    = date_scope.where(visitor_in_out: %w[out OUT]).count
    visitors[:in]           = base_scope.where(visitor_in_out: %w[in IN]).count
    visitors[:out]          = base_scope.where(visitor_in_out: %w[out OUT]).count

    # ── by_in_out ───────────────────────────────────────────────────────────────
    in_out_counts = date_scope
      .group("UPPER(COALESCE(NULLIF(visitors.visitor_in_out,''), 'PENDING'))")
      .count
    visitors[:by_in_out] = build_visitor_group(
      date_scope, 'in_out', in_out_counts,
      ->(scope, val) {
        val == 'PENDING' ? scope.where(visitor_in_out: [nil, '']) : scope.where("UPPER(visitors.visitor_in_out) = ?", val)
      },
      count_type, count_value, record_page
    )

    # ── by_entry_type (Expected vs Unexpected) ──────────────────────────────────
    entry_counts = {
      'Expected'   => visitors[:expected_v],
      'Unexpected' => visitors[:unexpected_v]
    }
    visitors[:by_entry_type] = build_visitor_group(
      date_scope, 'entry_type', entry_counts,
      ->(scope, val) {
        val == 'Expected' ? scope.joins(:created_by).where.not(users: { user_type: 'security_guard' })
                          : scope.joins(:created_by).where(users: { user_type: 'security_guard' })
      },
      count_type, count_value, record_page
    )

    # ── by_visit_type ───────────────────────────────────────────────────────────
    visit_type_counts = date_scope
      .joins("LEFT JOIN generic_sub_infos AS vsc ON vsc.id = visitors.visitor_staff_category_id")
      .group("COALESCE(NULLIF(vsc.name,''), NULLIF(visitors.visit_type,''), 'Walk-in')")
      .count
    visitors[:by_visit_type] = build_visitor_group(
      date_scope, 'visit_type', visit_type_counts,
      ->(scope, val) {
        scope.joins("LEFT JOIN generic_sub_infos AS vsc ON vsc.id = visitors.visitor_staff_category_id")
             .where(
               val == 'Walk-in' ? "vsc.name IS NULL AND (visitors.visit_type IS NULL OR visitors.visit_type = '')"
                                : "vsc.name = :v OR visitors.visit_type = :v", v: val
             )
      },
      count_type, count_value, record_page
    )

    # ── by_purpose ──────────────────────────────────────────────────────────────
    purpose_counts = date_scope
      .group("COALESCE(NULLIF(TRIM(visitors.purpose),''), 'Not Specified')")
      .count
    visitors[:by_purpose] = build_visitor_group(
      date_scope, 'purpose', purpose_counts,
      ->(scope, val) {
        val == 'Not Specified' ? scope.where("visitors.purpose IS NULL OR TRIM(visitors.purpose) = ''")
                               : scope.where("TRIM(visitors.purpose) = ?", val)
      },
      count_type, count_value, record_page,
      key_transform: ->(k) { k.to_s.truncate(60) }
    )

    # ── by_frequency ────────────────────────────────────────────────────────────
    freq_counts = date_scope
      .group("COALESCE(NULLIF(visitors.frequency,''), 'once')")
      .count
    visitors[:by_frequency] = build_visitor_group(
      date_scope, 'frequency', freq_counts,
      ->(scope, val) { scope.where("COALESCE(NULLIF(visitors.frequency,''), 'once') = ?", val) },
      count_type, count_value, record_page
    )

    # ── by_created_by ────────────────────────────────────────────────────────────
    creator_counts = date_scope
      .joins("LEFT JOIN users AS cv ON cv.id = visitors.created_by_id")
      .group("TRIM(CONCAT(COALESCE(cv.firstname,''), ' ', COALESCE(cv.lastname,'')))")
      .count
    visitors[:by_created_by] = build_visitor_group(
      date_scope, 'created_by', creator_counts,
      ->(scope, val) {
        scope.joins("LEFT JOIN users AS cv ON cv.id = visitors.created_by_id")
             .where("TRIM(CONCAT(COALESCE(cv.firstname,''), ' ', COALESCE(cv.lastname,''))) = ?", val)
      },
      count_type, count_value, record_page,
      key_transform: ->(k) { k.to_s.strip.presence || 'Unknown' }
    )

    # ── hourly_trend ─────────────────────────────────────────────────────────────
    visitors[:hourly_trend] = visitor_hourly_trend(date_scope, site_id, date_range)

    # ── monthly_trend ─────────────────────────────────────────────────────────────
    visitors[:monthly_trend] = visitor_monthly_trend(site_id)

    render json: visitors
  end

  # Drill-down: paginated visitor records for a given filter_type / filter_value
  # Params: site_id, filter_type, filter_value, start_date, end_date, page, per_page
  def visitors_drill
    site_id     = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    filter_type = params[:filter_type].to_s
    filter_value = params[:filter_value].to_s
    per_page    = [[(params[:per_page] || params[:limit] || VISITORS_PER_PAGE).to_i, 1].max, 200].min
    page        = [params[:page].to_i, 1].max

    start_date  = params[:start_date].presence&.to_date
    end_date    = params[:end_date].presence&.to_date
    date_range  = visitor_date_range(start_date, end_date)

    scope = Visitor.where(site_id: site_id).where(is_deleted: false)
                   .includes(:visitor_staff_category, :created_by)

    scope = scope.where(created_at: date_range) if date_range

    case filter_type
    when "in_out"
      if filter_value == "PENDING"
        scope = scope.where(visitor_in_out: [nil, ""])
      else
        scope = scope.where("UPPER(visitors.visitor_in_out) = ?", filter_value.upcase)
      end
    when "entry_type"
      if filter_value == "Expected"
        scope = scope.joins(:created_by).where.not(users: { user_type: 'security_guard' })
      else
        scope = scope.joins(:created_by).where(users: { user_type: 'security_guard' })
      end
    when "visit_type"
      scope = scope
        .joins("LEFT JOIN generic_sub_infos AS vsc ON vsc.id = visitors.visitor_staff_category_id")
        .where(
          filter_value == 'Walk-in' ? "vsc.name IS NULL AND (visitors.visit_type IS NULL OR visitors.visit_type = '')"
                                    : "vsc.name = :v OR visitors.visit_type = :v", v: filter_value
        )
    when "purpose"
      if filter_value == "Not Specified"
        scope = scope.where("visitors.purpose IS NULL OR TRIM(visitors.purpose) = ''")
      else
        scope = scope.where("TRIM(visitors.purpose) = ?", filter_value)
      end
    when "frequency"
      scope = scope.where("COALESCE(NULLIF(visitors.frequency,''), 'once') = ?", filter_value)
    when "created_by"
      scope = scope
        .joins("LEFT JOIN users AS cv ON cv.id = visitors.created_by_id")
        .where("TRIM(CONCAT(COALESCE(cv.firstname,''), ' ', COALESCE(cv.lastname,''))) = ?", filter_value)
    when "expected"
      scope = scope.joins(:created_by).where.not(users: { user_type: 'security_guard' })
    when "unexpected"
      scope = scope.joins(:created_by).where(users: { user_type: 'security_guard' })
    when "in"
      scope = scope.where(visitor_in_out: %w[in IN])
    when "out"
      scope = scope.where(visitor_in_out: %w[out OUT])
    end

    paginated = scope.order(created_at: :desc).page(page).per(per_page)

    render json: {
      filter_type:  filter_type,
      filter_value: filter_value,
      count:        paginated.total_count,
      total_pages:  paginated.total_pages,
      current_page: paginated.current_page,
      per_page:     per_page,
      records:      paginated.map { |v| visitor_record_details(v) }
    }
  end

  def export_visitors
    site_id = params[:site_ids].present? ? params[:site_ids].split(",") : [@user.current_site_id]

    # Get visitors based on user permissions
    @visitors = if @user.user_type == 'pms_admin' || @user.user_type == 'security_guard'
      Visitor.where(site_id: site_id)
    else
      Visitor.where(site_id: site_id, created_by_id: @user.id)
    end.includes(:extra_visitors, :profile_pic, :visitor_visits, :hosts, :created_by, :site, :visitor_staff_category)

    # Apply date filtering if provided
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day
      @visitors = @visitors.where(created_at: start_date..end_date)
    end

    # Apply filter type if provided
    if params[:filter_type].present?
      case params[:filter_type]
      when 'total_in'
        # Filter visitors who are currently in (based on visitor status)
        @visitors = @visitors.where(status: 'in')
      when 'total_out'
        # Filter visitors who are currently out (based on visitor status)
        @visitors = @visitors.where(status: 'out')
      when 'today_in'
        # Filter visitors who checked in today
        today = Date.current
        @visitors = @visitors.joins(:visitor_visits)
        .where(visitor_visits: { check_in: today.beginning_of_day..today.end_of_day })
        .where.not(visitor_visits: { check_in: nil })
        .distinct
      when 'today_out'
        # Filter visitors who checked out today
        today = Date.current
        @visitors = @visitors.joins(:visitor_visits)
        .where(visitor_visits: { check_out: today.beginning_of_day..today.end_of_day })
        .where.not(visitor_visits: { check_out: nil })
        .distinct
      end
    end

    @visitors = @visitors.order(created_at: :desc)

    respond_to do |format|
      format.xlsx do
        filename_suffix = if params[:start_date].present? && params[:end_date].present?
          "_#{params[:start_date]}_to_#{params[:end_date]}"
        elsif params[:filter_type].present?
          "_#{params[:filter_type]}"
        else
          "_#{Date.current.strftime('%Y%m%d')}"
        end

        response.headers['Content-Disposition'] = "attachment; filename=\"visitors_export#{filename_suffix}.xlsx\""
      end
      format.json do
        # Build the download URL with token parameter
        download_params = {
          format: :xlsx,
          site_ids: params[:site_ids]
        }
        download_params[:token] = params[:token] if params[:token].present?
        download_params[:start_date] = params[:start_date] if params[:start_date].present?
        download_params[:end_date] = params[:end_date] if params[:end_date].present?
        download_params[:filter_type] = params[:filter_type] if params[:filter_type].present?

        download_url = export_visitors_visitors_url(download_params)

        render json: {
          success: true,
          message: 'Export ready for download',
          download_url: download_url,
          filename: "visitors_export#{filename_suffix}.xlsx",
          total_records: @visitors.count,
          filter_applied: params[:filter_type] || 'all_records',
          date_range: params[:start_date].present? ? "#{params[:start_date]} to #{params[:end_date]}" : "All dates"
        }
      end
      format.html { redirect_to visitors_path, alert: 'Invalid format requested' }
    end
  end

  def download_visitors_export
    site_id = params[:site_ids].present? ? params[:site_ids].split(",") : [@user.current_site_id]

    # Get visitors based on user permissions
    @visitors = if @user.user_type == 'pms_admin' || @user.user_type == 'security_guard'
      Visitor.where(site_id: site_id)
    else
      Visitor.where(site_id: site_id, created_by_id: @user.id)
    end.includes(:extra_visitors, :profile_pic, :visitor_visits, :hosts, :created_by, :site, :visitor_staff_category)

    # Apply date filtering if provided
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day
      @visitors = @visitors.where(created_at: start_date..end_date)
    end

    @visitors = @visitors.order(created_at: :desc)

    # Dynamic filename based on date range
    filename_suffix = if params[:start_date].present? && params[:end_date].present?
      "_#{params[:start_date]}_to_#{params[:end_date]}"
    else
      "_#{Date.current.strftime('%Y%m%d')}"
    end

    # Render the XLSX template directly
    render xlsx: 'export_visitors',
      filename: "visitors_export#{filename_suffix}.xlsx",
      disposition: 'attachment'
  end


  def user_visitors
    # Fetch all hosts associated with the user
    hosts = @user.hosts
    # binding.pry

    # Get all visitors from those hosts
    visitors = Visitor.where(id: hosts.pluck(:visitor_id)).distinct

    # Render visitors in JSON format
    render json: visitors.as_json(
      #only: [:id, :name, :contact_no,:purpose, :site_id, :coming_from, :vehicle_number]
      methods: [:created_by_name],
      include: {
        hosts: {
          #only: [:id, :created_at],
          methods: :host_details
        }
      }
    )
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User or associated visitors not found' }, status: :not_found
  end

  def renotify_host
    visitor = Visitor.find(params[:id])
    host = visitor.hosts.find_by(user_id: params[:user_id])

    unless host
      render json: { error: "Host Not Found!" }, status: :not_found
      return
    end
    if visitor.skip_host_approval != true
      VisitorNotificationJob.perform_later(visitor.id, "reminder")
    end
    render json: { message: "Host Notified successfully" }, status: :ok
  end



  #-------------------------------------------- Private Method --------------------------------------

  private

  def create_associated_records(visitor)
    # Check if visitor was created by security guard
    # created_by_user = User.find_by(id: visitor.created_by_id)
    # is_security_guard = created_by_user&.user_type == 'security_guard'

    if !params[:visitor][:host_ids].present? && visitor.vhost_id.present?
      user = User.find_by(id: visitor.vhost_id)
    end
    if user
      host_params = {
        visitor_id: visitor.id,
        user_id: user.id,
        is_approved: (visitor.skip_host_approval || (visitor.created_by_id == user.id) ) ? true : nil,
        updated_at: visitor.skip_host_approval ? Time.current : nil
        # is_approved: (visitor.skip_host_approval || (visitor.created_by_id == user.id) || is_security_guard) ? true : nil,
        # updated_at: (visitor.skip_host_approval || is_security_guard) ? Time.current : nil
      }
      host = Host.new(host_params)
      unless host.save
        Rails.logger.error "Failed to create Host: #{host.errors.full_messages.join(', ')}"
      end
    elsif params[:visitor][:host_ids].present?
      params[:visitor][:host_ids].split(",").each do | user_id |
        user = User.find_by(id: user_id)

        if user
          host_params = {
            visitor_id: visitor.id,
            user_id: user.id,
            is_approved: (visitor.skip_host_approval || (visitor.created_by_id == user.id) ) ? true : nil,
            updated_at: visitor.skip_host_approval ? Time.current : nil
          }
          host = Host.new(host_params)
          unless host.save
            Rails.logger.error "Failed to create Host: #{host.errors.full_messages.join(', ')}"
          end
        end

      end

    else
      Rails.logger.error "No user found with id: #{visitor.created_by_id}"
    end

    # Set visitor status to true if created by security guard
    # if is_security_guard
    #   visitor.update(status: true)
    # end

    visitor_visit = VisitorVisit.create(visitor_id: visitor.id, check_in: nil, check_out: nil)
    unless visitor_visit.persisted?
      Rails.logger.error "Failed to create VisitorVisit: #{visitor_visit.errors.full_messages.join(', ')}"
    end
  end


  def send_otp(visitor)
    otp = generate_otp
    visitor.update(otp: otp)
    puts "Host: #{current_host}"
    puts "OTP for #{visitor.contact_no}: #{otp}"
    current_host = request.host
    web_url = case current_host
    when "app.myciti.life"
      "https://myciti.life/otp-qr?v=#{visitor.id}"
    when "admin.vibecopilot.ai"
      "https://app.vibecopilot.ai/otp-qr?v=#{visitor.id}  "
    else
      "https://myciti.life/otp-qr?v=#{visitor.id}" # Default URL if host doesn't match
    end
    message = case current_host
    when "app.myciti.life"
      "Dear #{visitor.name},

Please complete your visit request using the One-Time Password #{otp}.
Alternatively, you can scan the QR code below to quickly complete the verification process.

QR Link - #{web_url}

Thank You!

Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"
    when "admin.vibecopilot.ai"
      "Dear #{visitor.name},

Please complete your visit request using the One-Time Password #{otp}.
Alternatively, you can scan the QR code below to quickly complete the verification process.

QR Link - #{web_url}

Thank You!

Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"
    when "app.myciti.life"
      "Dear #{visitor.name},

You've been registered as a visitor on the Bhoomi Celestia site. Your OTP to visit is #{otp}. You can access your digital gate pass from this URL - #{web_url}

Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"
    else
      ""
    end

    begin

      require "uri"
      require "net/http"


      if current_host == "app.myciti.life"
        url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{visitor.contact_no}&source=VBCONN&message=#{message}&entityid=1201173433382664591&tempid=1207173989279594259")
      elsif current_host == "admin.vibecopilot.ai"
        url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{visitor.contact_no}&source=VBCONN&message=#{message}&entityid=1201173433382664591&tempid=1207173989279594259")
      else current_host == "app.myciti.life"
        url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{visitor.contact_no}&source=MCITIL&message=#{message}&entityid=1201173433382664591&tempid=1207174876323712614")
      end

      http = Net::HTTP.new(url.host, url.port);
      request = Net::HTTP::Get.new(url)

      response = http.request(request)
      puts response.read_body

    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end


    if visitor&.vhost_id.present? && !visitor.skip_host_approval == true
      # host = Host.find(visitor&.vhost_id)
      user = User.find_by(id: visitor.vhost_id)

      url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{user&.mobile}&source=VBCONN&message=Dear #{user.firstname} #{user.lastname}, visitor #{visitor.name} is waiting for approval. Please approve via the app.Thank you!Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED&entityid=1201173433382664591&tempid=1207173988526182520")

      http = Net::HTTP.new(url.host, url.port);
      request = Net::HTTP::Get.new(url)

      response = http.request(request)
      puts response.read_body
    end
  end


  def generate_otp
    rand(10000..99999).to_s
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_visitor
    @visitor = Visitor.find(params[:id])
  end

  def load_visitor_data
    category_info = GenericInfo.find_by(info_type: 'visitor_staff_category', site_id: @user.current_site_id)
    @visitor_staff_categories = category_info ? GenericSubInfo.where(generic_info_id: category_info.id) : []
  end


  def authorize_host
    @host = @visitor.hosts.find_by(user_id: current_user.id)
    render json: { error: 'You are not authorized to perform this action' }, status: :forbidden unless @host
  end

  VISITORS_PER_PAGE = 10

  def visitor_record_details(v)
    {
      id:              v.id,
      name:            v.name,
      contact_no:      v.contact_no,
      purpose:         v.purpose,
      visit_type:      v.visitor_staff_category&.name || v.visit_type || 'Walk-in',
      visitor_in_out:  v.visitor_in_out,
      frequency:       v.frequency.presence || 'once',
      pass_number:     v.pass_number,
      expected_date:   v.expected_date,
      coming_from:     v.coming_from,
      company_name:    v.site&.company&.name,
      created_at:      v.created_at,
      created_by:      v.created_by&.full_name,
      created_by_type: v.created_by&.user_type == 'security_guard' ? 'Unexpected' : 'Expected'
    }
  end

  # Shared group-builder: same pattern as complaints_dashboard
  def build_visitor_group(base_scope, filter_type, counts_hash, scope_filter_proc,
                          count_type, count_value, record_page,
                          key_transform: ->(k) { k.to_s })
    result       = {}
    load_records = (count_type == filter_type)

    counts_hash.each do |key, count|
      display_key = key_transform.call(key)

      if load_records && count_value.present? && count_value == display_key
        filtered  = scope_filter_proc.call(base_scope, key)
                      .includes(:visitor_staff_category, :created_by)
                      .order(created_at: :desc)
                      .page(record_page).per(VISITORS_PER_PAGE)
        result[display_key] = {
          count:        count,
          records:      filtered.map { |v| visitor_record_details(v) },
          total_pages:  filtered.total_pages,
          current_page: filtered.current_page,
          per_page:     VISITORS_PER_PAGE
        }
      else
        result[display_key] = count
      end
    end
    result
  end

  def visitor_date_range(start_date, end_date)
    if start_date && end_date
      start_date.beginning_of_day..end_date.end_of_day
    elsif start_date
      start_date.beginning_of_day..start_date.end_of_day
    elsif end_date
      end_date.beginning_of_day..end_date.end_of_day
    end
  end

  # Hourly breakdown (0–23) for the selected date range.
  # Returns registrations per hour AND check-ins per hour.
  def visitor_hourly_trend(date_scope, site_id, date_range)
    # Registrations per hour
    reg_by_hour = date_scope
      .group("HOUR(visitors.created_at)")
      .count
    reg_map = reg_by_hour.transform_keys(&:to_i)

    # Check-ins per hour from visitor_visits
    visits_scope = VisitorVisit
      .joins(:visitor)
      .where(visitors: { site_id: site_id, is_deleted: false })
      .where(is_deleted: false)
    visits_scope = visits_scope.where(check_in: date_range) if date_range

    checkin_by_hour  = visits_scope.group("HOUR(visitor_visits.check_in)").count
    checkout_by_hour = visits_scope.where.not(check_out: nil)
                                   .group("HOUR(visitor_visits.check_out)").count
    checkin_map  = checkin_by_hour.transform_keys(&:to_i)
    checkout_map = checkout_by_hour.transform_keys(&:to_i)

    (0..23).map do |h|
      label = format("%02d:00", h)
      {
        hour:          h,
        label:         label,
        registrations: reg_map[h] || 0,
        check_ins:     checkin_map[h] || 0,
        check_outs:    checkout_map[h] || 0
      }
    end
  end

  # Monthly breakdown for the last 12 months.
  # Returns registrations per month AND check-ins per month.
  def visitor_monthly_trend(site_id)
    from = 11.months.ago.beginning_of_month
    to   = Time.zone.now.end_of_month

    # Registrations per month
    reg_by_month = Visitor
      .where(site_id: site_id, is_deleted: false)
      .where(created_at: from..to)
      .group("DATE_FORMAT(visitors.created_at, '%Y-%m')")
      .count

    # Check-ins per month
    checkin_by_month = VisitorVisit
      .joins(:visitor)
      .where(visitors: { site_id: site_id, is_deleted: false })
      .where(is_deleted: false)
      .where(check_in: from..to)
      .group("DATE_FORMAT(visitor_visits.check_in, '%Y-%m')")
      .count

    # Build a complete 12-month series so months with 0 still appear
    (0..11).map do |offset|
      month_start = (11 - offset).months.ago.beginning_of_month
      key         = month_start.strftime("%Y-%m")
      label       = month_start.strftime("%b %Y")
      {
        month:         key,
        label:         label,
        registrations: reg_by_month[key] || 0,
        check_ins:     checkin_by_month[key] || 0
      }
    end
  end

  # Only allow a list of trusted parameters through.
  def visitor_params
    params = self.params.require(:visitor).permit(
      :name, :contact_no, :purpose, :site_id, :vhost_id,:parent_id,
      :coming_from, :vehicle_number, :expected_date, :expected_time,:pass_start_date,:pass_end_date,
      :skip_host_approval, :goods_inwards, :visit_type, :frequency, :parking_slot, :visitor_in_out,
      :status, :created_by_id, :start_pass, :end_pass, :is_deleted ,:pass_number,:unit_id ,:building_id, :visitor_staff_category_id,
      :qr_pending_expiry_minutes,
      { working_days: [] },
      extra_visitors_attributes: [:id, :name, :contact_no, :_destroy],
      visitor_files: []
    )
    # Filter out empty strings from working_days
    params[:working_days] = params[:working_days].reject(&:empty?) if params[:working_days]

    # Set skip_host_approval based on user's role
    # user = User.find_by(id: params[:created_by_id])
    # if user && user.user_type == 'security_guard'
    #   params[:skip_host_approval] = false
    # end

    # Remove this line if you want to allow manual status changes
    # params.delete(:status)  # This ensures status is not set directly from params

    params
  end
end
