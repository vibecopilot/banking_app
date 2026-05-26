class UsersController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_html_format, except: :change_site_for_app
  before_action :set_user, except: [:login, :preflight , :forgot , :verify_otp, :change_password, :reset, :update]
  before_action :verify_authenticity_token, if: :check_html_format
  before_action :api_user, except: [:login, :preflight , :forgot , :otp_request , :change_password , :verify_otp_by_mobile, :reset, :create]
  skip_before_action :authenticate_user! , only: [:get_bg_image, :get_goyal_park]
  skip_before_action :api_user, only: [:get_bg_image, :get_goyal_park]

  def login
    # @user = User.find_by_email(params[:user][:email]) || User.find_by_mobile(params[:user][:mobile])
    @user = nil
    @user = User.find_by_email(params[:user][:email]) unless params[:user][:email].blank?
    @user ||= User.find_by_mobile(params[:user][:mobile]) unless params[:user][:mobile].blank?
    if !@user.present? || !@user.valid_password?(params[:user][:password]) || !@user.user_status
      render  json: { "code": 401, "error": "Email / Mobile or Password not valid"}, :status => 200 and return
    end
    if @user.api_key.blank?
      @user.api_key = SecureRandom.hex(24)
      @user.save!
    end
    if @user.user_type == 'pms_occupant_admin' || @user.user_type == 'pms_occupant'
      features_list = ["tickets","cam_bill","document_pro","face_recognition","hrms", "gatepass", "visitor", "registered_vehicles", "staff", "patrolling", "good_in_and_out", "bookings", "field_sense", "fnb", "mailroom", "contacts", "business_cards", "space", "communication", "meeting", "doctors", "insurances", "bills", "fitness", "transport", "parking", "personal_finance", "calendar", "project_task", "bill_pay", "advance_salary", "birthday", "task", "copilot", "integration","other_projects","about_us"]
      features =  Feature.where(site_id: @user.current_site_id,feature_name:features_list)
    else
      features =  Feature.where(site_id: @user.current_site_id)
    end
    card_id = ""
    if @user.cards.present?
      card_id = @user.cards.first.card_id
    end
    lotus_ble_key = Site.find_by(id: @user.selected_site_id)&.lotus_ble_key.presence || ""
    render json: { "user": {
                     "id": @user.id,
                     "user_type": @user.user_type,
                     "member_type": @user.user_sites&.first&.ownership_type,
                     "lad_long_required": @user.lad_long_required,
                     "email": @user.email,
                     "firstname": @user.firstname,
                     "lastname": @user.lastname,
                     "lotus_card_id": card_id,
                     "lotus_ble_key": lotus_ble_key,
                     "api_key": @user.api_key,
                     "unit_id": @user&.unit_id || @user.user_sites&.pluck(:unit_id)&.first,
                     # "unit_name": Unit.find_by(id: @user.unit_id).try(:name),
                     "unit_name": @user.unit_id.present? ? Unit.find_by(id: @user.unit_id)&.name.to_s : "",
                     "selected_site_id": @user.current_site_id,
                     "company_id": @user.site.try(:company_id),
                     "organization_id": @user.organization_id,
                     "mobile": @user.mobile
                   },
                   "statuses": ComplaintStatus.active.where(society_id: @user.current_site_id),
                   "categories": HelpdeskCategory.active.where(society_id: @user.current_site_id),
                   "buildings": Building.where(site_id: @user.current_site_id),
                   "features": features,
                   "site": Site.find_by(id: @user.current_site_id),
                   "user_sites": @user.user_sites,
                   "remove_expected_datetime": GenericInfo.find_by(name: "remove_expected_datetime",company_id: @user.company_id)&.info_type,
                   "remove_vehicle_number": GenericInfo.find_by(name: "remove_vehicle_number",company_id: @user.company_id)&.info_type,
                   "remove_additional_visitor": GenericInfo.find_by(name: "remove_additional_visitor",company_id: @user.company_id)&.info_type,
                   "remove_visitor_purpose": GenericInfo.find_by(name: "remove_visitor_purpose",company_id: @user.company_id)&.info_type,
                   "remove_visitor_type": GenericInfo.find_by(name: "remove_visitor_type",company_id: @user.company_id)&.info_type,
                   "remove_staff_category": GenericInfo.find_by(name: "remove_staff_category",company_id: @user.company_id)&.info_type,
                   "remove_frequently_visitor": GenericInfo.find_by(name: "remove_frequently_visitor",company_id: @user.company_id)&.info_type
                   }
  end

  def preflight
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    head :ok
  end

  def update_user_request
    if params[:id].present?
      @user = User.find_by(id: params[:id])
      @user.update(delete_request: params[:delete_request])
      render json: { message: 'Request Sent Successfully' }, status: :ok
    end
  end
  def verify_otp
    user = User.find_by(otp: params[:otp])
    if !user.present?
      render json: { error: "Invalid or expired OTP" }, status: :not_found and return
    end
    if user.verify_otp(params[:otp])
      render json: { message: "OTP verified successfully.", email: user.email}, status: :ok
    else
      render json: { error: "OTP verification failed" }, status: :unprocessable_entity
    end
  end

  def otp_request
    user = User.find_by(mobile: params[:mobile])
    unless user
      return render json: { error: 'User not found' }, status: :not_found
    end

    begin
      otp = SecureRandom.random_number(10**6).to_s.rjust(6, '0')
      user.update!(otp: otp, otp_sent_at: Time.current)
      UserMailer.send_otp(user, otp).deliver_now
      sms_message = "Dear #{user.fullname},

Please complete your visit request using the One-Time Password #{otp}.

Thank You!
Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"

      encoded_message = CGI.escape(sms_message)

      sms_url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{user.mobile}&source=VBCONN&message=#{encoded_message}&entityid=1201173433382664591&tempid=1207175212113788801")

      http = Net::HTTP.new(sms_url.host, sms_url.port)
      request = Net::HTTP::Get.new(sms_url)
      response = http.request(request)
      Rails.logger.info "SMS API Response: #{response.body}"

      render json: { message: 'OTP sent successfully' }, status: :ok

    rescue StandardError => e
      Rails.logger.error "OTP Error: #{e.message}"
      render json: { error: 'Failed to send OTP' }, status: :unprocessable_entity
    end
  end

  #Verify Otp
  def verify_otp_by_mobile
    user = User.find_by(mobile: params[:mobile], otp: params[:otp])
    if user && user.otp == params[:otp].to_s
      if user.otp_sent_at > 10.minutes.ago
        user.update!(otp: nil)
        user.update!(user_status: 1)
        introducer = User.find_by(id: user.rbm_by_id)
        introducer_name = introducer.present? ? "#{introducer.firstname} #{introducer.lastname}" : nil
        render json: {
          status: 200,
          message: 'Login successful',
          token: user.api_key,
          member: {
            id: user.id,
            user_type: user.user_type,
            email: user.email,
            firstname: user.firstname,
            lastname: user.lastname,
            date_of_birth: user.birth_date,
            api_key: user.api_key,
            selected_site_id: user.current_site_id,
            mobile: user.mobile,
            user_status: user.user_status,
            rotary_club: user.rotary_club,
            wedding_date: user.wedding_date,
            business_name: user.business_name,
            introduce_rbm_by: introducer_name,
            business_category: user.business_category,
            education_qualification: user.education_qualification,
            resident_address: user.user_address,
            office_address: user.office_address,
            facebook: user.facebook_link,
            instagram: user.instagram_link,
            linkedin_profile: user.linkedin_profile,
            date_of_joining: user.date_of_joining,
            blood_group: user.blood_group
          }
        }, status: :ok
      else
        render json: { error: 'OTP has expired' }, status: :unauthorized
      end
    else
      render json: { status: 401, error: 'Invalid OTP or user' }, status: :unauthorized
    end
  end

  def forgot
    user = User.find_by_email(params[:email]) || User.find_by_mobile(params[:mobile])
    if user
      otp = rand(100000..999999) # Generate a 6-digit OTP
      user.update!(otp: otp)
      UserMailer.send_otp(user, otp).deliver_now
      sms_message = "Dear #{user.fullname},

We received a request to reset your password. To complete the process, please use the following One-Time Password: #{otp}

This OTP is valid for the next 10 minutes. Please enter it on the password reset page to proceed.

Thank You!

Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"
      encoded_message = CGI.escape(sms_message)
      sms_url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{user.mobile}&source=VBCONN&message=#{encoded_message}&entityid=1201173433382664591&tempid=1207173989148090531")

      http = Net::HTTP.new(sms_url.host, sms_url.port)
      request = Net::HTTP::Get.new(sms_url)
      response = http.request(request)
      puts "#{response.body}"
      # Log response (for debugging)
      Rails.logger.info "SMS API Response: #{response.body}"

      render json: { message: 'OTP sent successfully', otp: otp, email: user.email }, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def reset
    user = User.find_by(email: params[:email]) || User.find_by(mobile: params[:email])
    if user
      user.update(password: params[:password])
      render json: { message: 'Password reset successfully' }, status: :ok
    else
      render json: { error: 'Invalid or expired reset password token' }, status: :unprocessable_entity
    end
  end

  def change_password
    user = User.find_by(email: params[:email]) || User.find_by(mobile: params[:email]) || User.find_by(api_key: params[:token])
    password = params[:password]

    if user.present?
      user.password = params[:password]
      user.password_confirmation = params[:password]
      user.save
      render json: { message: 'Password reset successfully' }, status: :ok
    else
      render json: { message: 'Error while Resetting Password' }, status: :unprocessable_entity
    end
  end

  def change_site_for_app
    @user = User.find_by(api_key: params[:token])
    @user.update(current_site_id: params[:siteid])
    render json: { id: @user.id, siteid: @user.current_site_id }, status: :ok
  end

  def change_site
    @user.update(current_site_id: params[:siteid])
    redirect_to request.referer
  end

  def get_user_site
    sites = @user.sites.map { |e| { name_with_region: e.name_with_region, id: e.id, name:e.name } }
    render json: { sites: sites }, status: :ok
  end

  def categories
    render json: {
      "statuses": ComplaintStatus.active.where(society_id: @user.current_site_id) ,
      "categories": HelpdeskCategory.active.where(society_id: @user.current_site_id),
      "buildings": Building.where(site_id: @user.current_site_id),
      "features": Feature.where(site_id: @user.current_site_id)
    }
  end

  def index
    if @user.user_type == "pms_admin"
      @users = User.includes(:user_devices,
                             {user_sites: :site},
                             :unit,
                             :vendor,
                             :organization,
                             :company,
                             :site,
                             :user_sites,
                             :user_members,
                             :user_vendors,
                             :vehicle_details,
                             :communication_groups)
      .where(current_site_id: @user.current_site_id, active: true)
      .ransack(params[:q])
      .result
      .order(created_at: :desc)
    else
      if params[:format] == "json"
        @users = User.includes(:user_devices,
                               {user_sites: :site},
                               :unit,
                               :vendor,
                               :organization,
                               :company,
                               :site,
                               :user_sites,
                               :user_vendors,
                               :vehicle_details,
                               :user_members,
                               :communication_groups)
        .where(current_site_id: @user.current_site_id, active: true)
        .ransack({ user_sites_site_id_eq: @user.current_site_id }.merge(params[:q]&.to_unsafe_h || {})).result
        .order(created_at: :desc)
      else
        @users = User.includes(:user_devices,
                               {user_sites: :site},
                               :unit,
                               :vendor,
                               :organization,
                               :company,
                               :site,
                               :user_sites,
                               :user_vendors,
                               :vehicle_details,
                               :user_members,
                               :communication_groups)
        .where(current_site_id: @user.user_sites.pluck(:site_id), active: true)
        .ransack(params[:q])
        .result
        .order(created_at: :desc)
      end
    end
    respond_to do |format|
      format.html { render layout: 'basic' }
      format.json { render 'index.json.jbuilder' }
    end
  end

  # Building -> Floor -> Unit -> Users;
  def user_dropdown
    case params[:type]

    # ---------------- FLOORS ----------------
    when "floors"
      records = Floor
      .where(building_id: params[:building_id])
      .select(:id, :name)

      render json: records
      return

      # ---------------- UNITS ----------------
    when "units"
      records = Unit
      .where(floor_id: params[:floor_id])
      .select(:id, :name)

      render json: records
      return

      # ---------------- USERS ----------------
    when "users"
      users_scope = User
      .joins(user_sites: { unit: [:building, :floor] })
      .includes(user_sites: { unit: [:building, :floor], site: {} })
      .distinct

      # ---------- Filters ----------
      if params[:unit_id].present?
        users_scope = users_scope.where(user_sites: { unit_id: params[:unit_id] })
      end

      if params[:floor_id].present?
        users_scope = users_scope.where(units: { floor_id: params[:floor_id] })
      end

      if params[:building_id].present?
        users_scope = users_scope.where(units: { building_id: params[:building_id] })
      end

      if params[:ownership].present?
        users_scope = users_scope.where(user_sites: { ownership: params[:ownership] })
      end

      # ---------- Response Mapping ----------
      records = users_scope.map do |user|
        sites_hash = {}

        filtered_user_sites = user.user_sites
        filtered_user_sites = filtered_user_sites.where(unit_id: params[:unit_id]) if params[:unit_id].present?
        filtered_user_sites = filtered_user_sites.joins(:unit).where(units: { floor_id: params[:floor_id] }) if params[:floor_id].present?
        filtered_user_sites = filtered_user_sites.joins(:unit).where(units: { building_id: params[:building_id] }) if params[:building_id].present?
        filtered_user_sites = filtered_user_sites.where(ownership: params[:ownership]) if params[:ownership].present?

        filtered_user_sites.each do |us|
          site = us.site
          unit = us.unit
          next unless site && unit

          sites_hash[site.id] ||= {
            site_id: site.id,
            site_name: site.name,
            units: []
          }

          sites_hash[site.id][:units] << {
            unit_id: unit.id,
            unit_name: unit.name,
            building: unit.building&.name,
            floor: unit.floor&.name,
            ownership: us.ownership
          }
        end

        {
          id: user.id,
          name: "#{user.firstname} #{user.lastname}",
          email: user.email,
          mobile: user.mobile,
          address: user.user_address,
          sites: sites_hash.values
        }
      end

      render json: records
      return

    else
      render json: ["Not found"]
    end
  end


  def export_users
    # @users = User.where(user_type: ['rmb_member', 'rmb_admin']) # for Rmb Member
    # site_id = @user.current_site_id if @user.user_type == "pms_admin"
    site_id = @user.current_site_id

    if params[:user_type] == 'rmb_user'
      @users = User.where(user_type: ['rmb_member', 'rmb_admin'])
    else
      @users = User.joins(:user_sites).where(user_sites: { site_id: site_id }).distinct
    end

    respond_to do |format|
      format.xlsx do
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=users_sheet_#{Date.today}.xlsx"
      end
    end
  end


  def index_count
    @users = User
    .select(:id, :firstname, :lastname, :email, :mobile, :api_key)
    .includes(:user_devices, :user_sites => [:unit => [:floor, :building]])

    respond_to do |format|
      format.json
    end
  end


  def pms_admins
    is_admin = params[:admin] == "true"
    role_type = params[:type]
    site_id = @user.current_site_id
    base = User.where(current_site_id: site_id)

    if role_type == "technician"
      base = base.where(user_type: ['pms_technician', 'technician'])
    elsif is_admin
      base = base.where(user_type: ['pms_admin'])
    else
      base = base.where(user_type: ['pms_admin', 'pms_technician'])
    end

    @pms_admins_and_technicians = base
    render json: @pms_admins_and_technicians.map { |u|
      {
        id: u.id,
        full_name: u.full_name,
        email: u.email,
        user_type: u.user_type,
      }
    }
  end

  def new
    @newuser = User.new
    render :form, layout: "basic"
  end

  def show
    @newuser = User.find_by(id: params[:id])

    unless @newuser
      respond_to do |format|
        format.html { redirect_to users_path, alert: "User not found" }
        format.json { render json: { error: "User not found" }, status: :not_found }
      end
      return
    end

    respond_to do |format|
      format.html { render :form , layout: 'basic' }
      format.json { render 'show.json.jbuilder' }
    end
  end


  def send_welcome_email
    user = User.find_by(id: params[:id])
    if user
      password = SecureRandom.urlsafe_base64(6)
      user.password = password
      if user.save
        if user.current_site_id == 46
          UserMailer.new_user_welcome_mailer(user,password).deliver_now
        else
          UserMailer.user_welcome_mailer(user,password).deliver_now
          # puts "Hello"
          # UserMailer.user_welcome_mailer(user,password).deliver_later
        end

        respond_to do |format|
          format.html { redirect_to users_path, notice: "Mail sent successfully" }
          format.json { render json: { message: "Mail sent successfully", user: user }, status: :ok }
        end
      else
        respond_to do |format|
          format.html { redirect_to users_path, alert: "Failed to save user" }
          format.json { render json: { error: "Failed to save user" }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to users_path, alert: "User not found" }
        format.json { render json: { error: "User not found" }, status: :not_found }
      end
    end
  end
  def active_inactive_user
    if params[:id].present?
      @user = User.find_by(id: params[:id]) # Use find_by to prevent exceptions

      if @user.present?
        @user.update(active: params[:active]) # Ensure params[:active] is a boolean if necessary
        respond_to do |format|
          format.json { render json: { message: "User Updated" }, status: :ok }
        end
      else
        respond_to do |format|
          format.json { render json: { error: "User not found" }, status: :not_found }
        end
      end
    else
      respond_to do |format|
        format.json { render json: { error: "ID parameter is missing" }, status: :bad_request }
      end
    end
  end

  def create
    # binding.pry

    if params[:id].present?
      @newuser = User.find(params[:id])
      @newuser.update_attributes(user_params_wo_pass)
    else
      @newuser = User.new(user_params)
      @newuser.errors.add(:email, "already exists")
      # Check if email already exists
      existing_user = User.find_by(email: params[:user][:email])
      if existing_user
        respond_to do |format|
          format.html { render :form, layout: "basic" }
          format.json do
            render json: { success: false, error: "Email already exists. Please use a different email.", code: 422 },
              status: :unprocessable_entity
          end
        end
        return
      end

      # Check if mobile already exists
      # existing_mobile = User.find_by(mobile: params[:user][:mobile])
      # if existing_mobile
      #   respond_to do |format|
      #     format.html { render :form, layout: "basic" }
      #     format.json do
      #       render json: { success: false, error: "Mobile number already exists. Please use a different mobile number.", code: 422 },
      #         status: :unprocessable_entity
      #     end
      #   end
      #   return
      # end

      params[:password_confirmation] = params[:password]
      @newuser = User.new(user_params)
      @newuser.created_by_id = User.find_by(api_key: params[:token])&.id if params[:token].present?
      @newuser.user_type ||= "user"
    end
    respond_to do |format|
      if @newuser.save
        if params[:user][:site_ids].present?
          UserSite.where(user_id: @newuser.id).delete_all
          params[:user][:site_ids].reject(&:blank?).each do |sid|
            UserSite.create(user_id: @newuser.id, site_id: sid, unit_id: @newuser.unit_id)
          end
          @newuser.update(current_site_id: params[:current_site_id] || @newuser.sites.first&.id || 68)
          @newuser.welcome_email
        end

        if params[:user][:user_docs].present?
          params[:user_docs].each do |doc|
            Attachfile.create(image: doc, relation: "UserDocuments", relation_id: @newuser.id, active: 1)
          end
        end

        if params[:user][:user_sites].present?
          params[:user][:user_sites].each do |sid|
            # us = UserSite.find_or_initialize_by(user_id: @newuser.id, site_id: sid[:site_id], unit_id: sid[:unit_id])
            # us.is_approved = sid[:is_approved]
            # us.ownership = sid[:ownership]
            # us.ownership_type = sid[:ownership_type]
            # us.lives_here = sid[:lives_here]
            # us.save
            UserSite.create(
              sid.permit(:site_id, :unit_id, :ownership, :ownership_type, :is_approved, :lives_here, :build_id, :floor_id).merge(user_id: @newuser.id)
            )
          end
          @newuser.update(current_site_id: @newuser.sites.try(:first).try(:id))
          @newuser.welcome_email
        end

        # Multiple User Members
        if params[:user][:user_members].present?
          params[:user][:user_members].each do |member|
            next if member[:member_name].blank? # Skip if no name provided
            UserMember.create(
              member.permit(:member_type, :member_name, :contact_no, :relation)
              .merge(user_id: @newuser.id)
            )
          end
        end

        if params[:user][:user_vendors].present?
          params[:user][:user_vendors].each do |vendor|
            next if vendor[:name].blank? # Skip if no name provided
            UserVendor.create(
              vendor.permit(:contact_no, :name, :service_type).merge(user_id: @newuser.id)
            )
          end
        end

        # Multiple Vehicle Details
        if params[:user][:vehicle_details].present?
          params[:user][:vehicle_details].each do |vehicle|
            next if vehicle[:vehicle_no].blank? # Skip if no vehicle number provided
            VehicleDetail.create(
              vehicle.permit(:vehicle_type, :vehicle_no, :parking_slot_no).merge(user_id: @newuser.id)
            )
          end
        end

        if params[:user][:pet_details].present?
          params[:user][:pet_details].each do |pet|
            save_pet = @newuser.pets.create(
              pet.permit(
                :pet_name,
                :owner_mobile_no,
                :pet_breed,
                :gender,
                :colour,
                :age,
                :dob,
                :is_pet_transfered,
                :brought,
                :stray_pet_adopted,
                :whether_brought_from_current_city,
                :pet_born_to_owner_dog
              )
            )
            # Attachments Images
            if pet[:pet_images].present?
              pet[:pet_images].each do |doc|
                Attachfile.create(active:1, relation: "PetsImage", relation_id: save_pet.id, image: doc)
              end
            end

            #Profile Image
            if pet[:pet_profile].present?
              pet[:pet_profile].each do |doc|
                Attachfile.create!(active: 1, relation: "PetProfile", relation_id: save_pet.id, image: doc)
              end
            end
          end
        end
        # binding.pry
        format.html { redirect_to "/users", notice: "User added successfully" }
        format.json { render json: { success: true, message: "User created successfully", user: @newuser }, status: :created }
      else
        # binding.pry
        format.html { render :form, layout: "basic" }
        format.json do
          render json: { error: @newuser.errors.full_messages.join(', '), code: 422 },
            status: :unprocessable_entity
        end
      end
    end
  end

  def get_bg_image
    @image_data = [
      {key: "MycitiBG", label: "mumbai buildings", image: "#{request.base_url}/images/mumbai-skyline-skyscrapers-construction.jpg" },
      {key: "VibeBg", label: "Night view building", image: "#{request.base_url}/images/pexels-sibi-mathew-410029-1092063.jpg" },
      {key: "navBarImage", label: "Black Flames", image: "#{request.base_url}/images/pexels-rafael-guajardo-194140-604684.jpg"},
      {key: "VibeBg", label: "VibeImg1", image: "#{request.base_url}/images/pexels-zhangkaiyv-1139556.jpg"},
      {key: "VibeBg", label: "VibeImg2", image: "#{request.base_url}/images/pexels-sovianna-10967617.jpg"},
      # {key: "VibeBg", label: "Holi", image: "#{request.base_url}/Holi_Image.jpeg" },
      # {key: "VibeBg", label: "Holi", image: "#{request.base_url}/Holi_Image.jpeg" }
    ]
    render 'bg_images' ,format: :json
  end

  def get_goyal_park
    @image_data = [
      {key: "VibeBg", label: "Goyal Titanium", image: "#{request.base_url}/GoyalImages/WhiteField.png" },
      {key: "VibeBg", label: "Goyal Titanium", image: "#{request.base_url}/GoyalImages/Park4.png" },
      {key: "VibeBg", label: "Goyal Titanium", image: "#{request.base_url}/GoyalImages/Park3.png"},
      {key: "VibeBg", label: "Goyal Titanium", image: "#{request.base_url}/GoyalImages/Park2.png"},
      {key: "VibeBg", label: "TechPark", image: "#{request.base_url}/GoyalImages/GoyalPark_Night.png"},
      # {key: "VibeBg", label: "Holi", image: "#{request.base_url}/Holi_Image.jpeg" },
      # {key: "VibeBg", label: "Holi", image: "#{request.base_url}/Holi_Image.jpeg" }
    ]
    render 'bg_images' ,format: :json
  end

  def import
    @file = params[:file]
    @uploads = User.import(@file, @user)
    errors = @uploads.select { |r| r[:message] != "success" }
    if errors.any?
      # binding.pry
      sample = errors.first(3).map { |e| "Row #{e[:row_number]}: #{e[:message]}" }.join("; ")
      flash[:alert] = "#{errors.count} users were not imported. #{sample}"
    else
      flash[:notice] = "Successfully imported users"
    end
    redirect_back(fallback_location: users_path)
  end

  def destroy
    @user = User.find_by(id: params[:id])

    if @user
      @user.update(active: false)
      respond_to do |format|
        format.html { redirect_to request.referrer, notice: "User deleted successfully!" }
        format.json { render json: { message: "User deleted successfully!" }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to request.referrer, alert: "User not found!" }
        format.json { render json: { error: "User not found!" }, status: :not_found }
      end
    end
  end


  def update
    @user = User.find(params[:id])

    # Extract user_vendor_attributes before calling user_params
    user_vendor_attrs = params[:user].delete(:user_vendor_attributes) if params[:user][:user_vendor_attributes].present?

    if @user.update(user_params)
      # --------------------
      # Handle User Sites
      # --------------------
      if params[:user][:user_sites].present?
        incoming_sites = params[:user][:user_sites].map do |s|
          [s[:site_id].to_i, s[:unit_id].to_i]
        end

        # Destroy UserSites not present in incoming params
        @user.user_sites.each do |existing_site|
          existing_pair = [existing_site.site_id, existing_site.unit_id]
          unless incoming_sites.include?(existing_pair)
            existing_site.destroy
          end
        end

        # Create or update remaining UserSites
        params[:user][:user_sites].each do |s|
          us = UserSite.find_or_initialize_by(
            user_id: @user.id,
            site_id: s[:site_id],
            unit_id: s[:unit_id]
          )
          us.is_approved     = s[:is_approved]
          us.ownership       = s[:ownership]
          us.ownership_type  = s[:ownership_type]
          us.lives_here      = s[:lives_here]

          us.save!
        end

        @user.update(current_site_id: @user.sites.try(:first).try(:id))
        @user.welcome_email
      end

      # --------------------
      # Handle User Documents
      # --------------------
      if params[:user][:user_docs].present?
        params[:user][:user_docs].each do |doc|
          Attachfile.create(
            image: doc,
            relation: "UserDocuments",
            relation_id: @user.id,
            active: 1
          )
        end
      end

      # --------------------
      # Handle User Members
      # --------------------
      if params[:user][:user_members].present?
        # Optional: clean old members if not in params
        @user.user_members.destroy_all
        params[:user][:user_members].each do |member|
          UserMember.create(
            member.permit(:member_type, :member_name, :contact_no, :relation)
            .merge(user_id: @user.id)
          )
        end
      end

      # --------------------
      # Handle User Vendors
      # --------------------
      if params[:user][:user_vendors].present?
        # Optional: clean old vendors if not in params
        @user.user_vendors.destroy_all
        params[:user][:user_vendors].each do |vendor|
          UserVendor.create(
            vendor.permit(:contact_no, :name, :service_type)
            .merge(user_id: @user.id)
          )
        end
      end

      # Handle singular user_vendor_attributes
      if user_vendor_attrs.present?
        @user.user_vendors.destroy_all
        user_vendor_attrs.each do |vendor|
          UserVendor.create(
            vendor.permit(:contact_no, :name, :service_type)
            .merge(user_id: @user.id)
          )
        end
      end

      # --------------------
      # Handle Vehicle Details
      # --------------------
      if params[:user][:vehicle_details].present?
        # Optional: clean old vehicle details if not in params
        @user.vehicle_details.destroy_all
        params[:user][:vehicle_details].each do |vehicle|
          VehicleDetail.create(
            vehicle.permit(:vehicle_type, :vehicle_no, :parking_slot_no)
            .merge(user_id: @user.id)
          )
        end
      end

      if params[:user][:pet_details].present?
        params[:user][:pet_details].each do |pet|
          save_pet = @user.pets.create(
            pet.permit(
              :pet_name,
              :owner_mobile_no,
              :pet_breed,
              :gender,
              :colour,
              :age,
              :dob,
              :is_pet_transfered,
              :brought,
              :stray_pet_adopted,
              :whether_brought_from_current_city,
              :pet_born_to_owner_dog
            )
          )

          # Attachments
          if pet[:pet_images].present?
            pet[:pet_images].each do |doc|
              Attachfile.create(active:1, relation: "PetsImage", relation_id: save_pet.id, image: doc)
            end
          end
          #Profile Image
          if pet[:pet_profile].present?
            pet[:pet_profile].each do |doc|
              Attachfile.create!(active: 1, relation: "PetProfile", relation_id: save_pet.id, image: doc)
            end
          end
        end
      end
      render json: { success: true, message: "User updated successfully", user: @user }, status: :ok
    else
      render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    user = User.find(params[:id])
    apd_u = user.update(user_status: params[:user_status],is_admin_approved: params[:is_admin_approved])
    respond_to do |format|
      if apd_u
        format.html do
          redirect_to users_path, notice: "User status updated successfully."
        end
        format.json do
          render json: { message: "User approved successfully!" }, status: :ok
        end
      else
        format.html do
          redirect_to users_path, alert: "Failed to update user status."
        end

        format.json do
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end


  def pendig_admin_approvals

  end


  def update_user_sites
    if params[:site_ids].present?
      UserSite.where(user_id: @user.id).delete_all
      params[:site_ids].each do |sid|
        UserSite.create(user_id: @user.id, site_id: sid, unit_id: @user.unit_id)
      end
      @user.update(current_site_id: @user.sites.try(:first).try(:id))
    end

    if params[:user][:user_sites].present?
      params[:user][:user_sites].each do |sid|
        us = UserSite.find_or_initialize_by(user_id: @user.id, site_id: sid[:site_id], unit_id: sid[:unit_id])
        us.is_approved = sid[:is_approved]
        us.ownership = sid[:ownership]
        us.ownership_type = sid[:ownership_type]
        us.lives_here = sid[:lives_here]
        us.save
      end
      @user.update(current_site_id: @user.sites.try(:first).try(:id))
    end
  end

  def set_user
    return if params[:id].blank?
    @user = User.find_by(id: params[:id])
  end

  # private
  # def user_params
  #   params.require(:user).permit(:firstname, :lastname, :email, :mobile, :user_type, :unit_id, :password)
  # end

  def user_params
    params.require(:user).permit(:organization_id,:vendor_id,:delete_request, :is_admin_approved, :rbm_by_id, :otp_sent_at,
                                 :member_of_rmb,
                                 :facebook_link,
                                 :instagram_link,
                                 :linkedin_profile,
                                 :moving_date,
                                 :profession,
                                 :floor_id,
                                 :created_by_id,
                                 :mgl_customer_number,
                                 :adani_electricity_account_no,
                                 :net_provider_name,
                                 :net_provider_id,
                                 :date_of_joining, :blood_group, :lad_long_required, :user_courtesy, :current_site_id, :firstname, :lastname, :email, :mobile, :password, :user_type, :building_id, :unit_id, :user_phase, :user_status, :user_category_id, :user_address, :resident_type, :membership_type, :lives_here, :allow_fitout, :birth_date, :anniversary, :spouse_birth_date, :rotary_club, :wedding_date, :business_name, :business_category, :education_qualification, :office_address , :email_1, :email_2, :landline_number, :intercom_number, :gst_number, :pan_number, :ev_connection, :no_of_adults,:otp, :no_of_childrens, :no_of_pets, :differently_abled,:department_id,:manager_id,:about_me, :position, :connection,:company_id, :profile_image, :start_date, :end_date, :lotus_token,
                                 :helpdesk_category_id, :helpdesk_sub_category_id,
                                 user_sites_attributes: [
                                   :id, :site_id,:build_id, :floor_id ,:unit_id, :ownership, :ownership_type, :is_approved, :lives_here, :_destroy
                                 ],
                                 user_members_attributes: [ :id, :member_type ,:member_name ,:contact_no, :relation, :_destroy ],
                                 user_vendors_attributes: [ :id, :service_type, :name , :contact_no, :_destroy ],
                                 vehicle_details_attributes: [ :id, :vehicle_type, :vehicle_no, :parking_slot_no, :_destroy ],
                                 pets_attributes: [
                                   :pet_name,
                                   :owner_mobile_no,
                                   :pet_breed,
                                   :gender,
                                   :colour,
                                   :age,
                                   :dob,
                                   :is_pet_transfered,
                                   :brought,
                                   :stray_pet_adopted,
                                   :whether_brought_from_current_city,
                                   :pet_born_to_owner_dog,
                                   :is_approved,
                                   :approved_at,
                                   :rejection_reason,
                                   :approved_by_id
                                 ]
                                 )
  end

  def user_params_wo_pass
    params.require(:user).permit(:firstname, :lastname, :email, :mobile, :user_type, :unit_id, :password, :profile_image)
  end

  def reset_password_params
    params.permit(:reset_password_token, :password, :password_confirmation)
  end

  def sync_to_external_api
    @user = User.find_by(id: params[:id])

    unless @user
      return render json: { success: false, error: 'User not found' }, status: :not_found
    end

    company_id = params[:company_id] || 56
    service = ExternalUserSyncService.new(@user, company_id)
    result = service.sync

    respond_to do |format|
      if result[:success]
        format.json { render json: result, status: :ok }
      else
        format.json { render json: result, status: :unprocessable_entity }
      end
    end
  end

  def sync_users_batch
    company_id = params[:company_id] || 56
    user_ids = params[:user_ids] || []

    results = []
    user_ids.each do |user_id|
      user = User.find_by(id: user_id)
      next unless user.present?

      service = ExternalUserSyncService.new(user, company_id)
      result = service.sync
      results << { user_id: user_id, result: result }
    end

    render json: { success: true, synced_count: results.count, results: results }, status: :ok
  end

  # User.find_each do |user|
  #   next unless user.unit_id.present?
  #   user.user_sites.where(unit_id: nil).update_all(unit_id: user.unit_id)
  # end
end
