class EventCheckInsController < ApplicationController
  #skip_before_action :authenticate_user!, only: [:check_in, :check_otp]
  # def check_in
  #   @event = Event.find(params[:id])

  #   site_id = @event.site_id

  #   user_ids = UserSite.where(site_id: site_id).pluck(:user_id)

  #   @user = User.where(id: user_ids).find_by(mobile: params[:mobile]) # otp: params[:otp]

  #   if @user.present?
  #     @event_user = @event.event_users.create(user_id: @user.id)
  #   else
  #     event_guest = EventGuest.find_by(mobile: params[:mobile], otp: params[:otp])
  #     if event_guest.present?
  #       @event_user = @event.event_users.create(event_guest_id: event_guest.id)
  #     end
  #   end

  #   if @event_user
  #     # Update check-in status and time
  #     @event_user.update(checked_in_at: Time.current, rsvp: 'attended')
  #     render json: { success: true, message: 'Successfully checked in',  member: {
  #                      id: @user.id,
  #                      user_type: @user.user_type,
  #                      email: @user.email,
  #                      firstname: @user.firstname,
  #                      lastname: @user.lastname,
  #                      date_of_birth: @user.birth_date,
  #                      api_key: @user.api_key,
  #                      selected_site_id: @user.current_site_id,
  #                      mobile: @user.mobile,
  #                      rotary_club: @user.rotary_club,
  #                      wedding_date: @user.wedding_date,
  #                      business_name: @user.business_name,
  #                      # introduce_rbm_by: introducer_name,
  #                      business_category: @user.business_category,
  #                      education_qualification: @user.education_qualification,
  #                      resident_address: @user.user_address,
  #                      office_address: @user.office_address,
  #                      facebook: @user.facebook_link,
  #                      instagram: @user.instagram_link,
  #                      linkedin_profile: @user.linkedin_profile,
  #                      date_of_joining: @user.date_of_joining,
  #                      blood_group: @user.blood_group
  #                    }
  #                    }
  #   else
  #     render json: { success: false, message: 'Invalid OTP!' }, status: :unprocessable_entity
  #   end
  # rescue ActiveRecord::RecordNotFound
  #   render json: { success: false, message: 'Event not found' }, status: :not_found
  # end

  #   def check_in
  #     @event = Event.find(params[:id])

  #     unless second_or_fourth_saturday?(Date.today)
  #       return render json: { success: false, message: 'Check-in is only allowed on the 2nd and 4th Saturday of each month.' }, status: :forbidden
  #     end

  #     site_id = @event.site_id
  #     user_ids = UserSite.where(site_id: site_id).pluck(:user_id)
  #     @user = User.where(id: user_ids).find_by(mobile: params[:mobile])

  #     if @user.present?
  #       @event_user = @event.event_users.find_or_create_by(user_id: @user.id)
  #     else
  #       event_guest = EventGuest.find_by(mobile: params[:mobile], otp: params[:otp])
  #       if event_guest.present?
  #         @event_user = @event.event_users.find_or_create_by(event_guest_id: event_guest.id)
  #       end
  #     end

  #     if @event_user
  #       @event_user.update(checked_in_at: Time.current, rsvp: 'attended')
  #       render json: {
  #         success: true,
  #         message: 'Successfully checked in',
  #         member: {
  #           id: @user&.id,
  #           user_type: @user&.user_type,
  #           email: @user&.email,
  #           firstname: @user&.firstname,
  #           lastname: @user&.lastname,
  #           date_of_birth: @user&.birth_date,
  #           api_key: @user&.api_key,
  #           selected_site_id: @user&.current_site_id,
  #           mobile: @user&.mobile,
  #           rotary_club: @user&.rotary_club,
  #           wedding_date: @user&.wedding_date,
  #           business_name: @user&.business_name,
  #           business_category: @user&.business_category,
  #           education_qualification: @user&.education_qualification,
  #           resident_address: @user&.user_address,
  #           office_address: @user&.office_address,
  #           facebook: @user&.facebook_link,
  #           instagram: @user&.instagram_link,
  #           linkedin_profile: @user&.linkedin_profile,
  #           date_of_joining: @user&.date_of_joining,
  #           blood_group: @user&.blood_group
  #         }
  #       }
  #     else
  #       render json: { success: false, message: 'Invalid OTP!' }, status: :unprocessable_entity
  #     end

  #   rescue ActiveRecord::RecordNotFound
  #     render json: { success: false, message: 'Event not found' }, status: :not_found
  #   end

  #   private

  #   # Check if a date is 2nd or 4th Saturday of the month
  #   def second_or_fourth_saturday?(date)
  #     return false unless date.saturday?

  #     day = date.day
  #     (8..14).include?(day) || (22..28).include?(day)
  #   end



  #   def check_otp
  #     @event = Event.find(params[:id])

  #     site_id = @event.site_id

  #     user_ids = UserSite.where(site_id: site_id).pluck(:user_id)

  #     @user = User.where(id: user_ids).find_by(mobile: params[:mobile])

  #     if !@user.present?
  #       # @event_user = @event.event_users.create(user_id: @user.id)
  #       # else
  #       @user = EventGuest.find_by(mobile: params[:mobile])
  #       #@event_user = @event.event_users.create(event_guest_id: event_guest.id)

  #     end

  #     if @user
  #       begin
  #         otp = rand(100000..999999)
  #         @user.update!(otp: otp, updated_at: Time.current)
  #         var = "_"
  #         sms_message = "Dear #{@user.fullname},

  # Please complete your visit request using the One-Time Password #{otp}.
  # Alternatively, you can scan the QR code below to quickly complete the verification process.

  # QR Link - #{var}

  # Thank You!

  # Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"
  #         encoded_message = CGI.escape(sms_message)
  #         sms_url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{@user.mobile}&source=VBCONN&message=#{encoded_message}&entityid=1201173433382664591&tempid=1207173989279594259")

  #         http = Net::HTTP.new(sms_url.host, sms_url.port)
  #         request = Net::HTTP::Get.new(sms_url)
  #         response = http.request(request)
  #         puts "#{response.body}"
  #         # Log response (for debugging)
  #         Rails.logger.info "SMS API Response: #{response.body}"

  #       rescue StandardError => e

  #       end
  #       # Update check-in status and time
  #       #@event_user.update(checked_in_at: Time.current, rsvp: 'attended')
  #       render json: { success: true, message: 'Successfully Sent Otp on Mobile No.' }
  #     else
  #       render json: { success: false, message: 'User not registered!' }, status: :unprocessable_entity
  #     end
  #   rescue ActiveRecord::RecordNotFound
  #     render json: { success: false, message: 'Event not found' }, status: :not_found
  #   end

  # end


  def check_in
    @event = Event.find(params[:id])
    unless second_or_fourth_friday_or_saturday?(Date.today)
      return render json: { success: false, message: 'Check-in is only allowed on the 2nd and 4th Friday or Saturday of each month.' }, status: :forbidden
    end

    site_id = @event.site_id
    user_ids = UserSite.where(site_id: site_id).pluck(:user_id)
    @user = User.where(id: user_ids).find_by(mobile: params[:mobile])

    # Lookup guest (if user not found)
    event_guest = nil
    if @user.blank?
      event_guest = EventGuest.find_by(mobile: params[:mobile], otp: params[:otp])
    end

    begin
      # Build base conditions
      query = {
        event_id: @event.id,
        checked_in_at: Date.today.all_day
      }

      if @user.present?
        query[:user_id] = @user.id
      elsif event_guest.present?
        query[:event_guest_id] = event_guest.id
      else
        return render json: { success: false, message: 'Invalid OTP or mobile number' }, status: :unprocessable_entity
      end

      # Check if a check-in already exists for today
      existing_check_in = EventUser.where(query).first

      if existing_check_in
        existing_check_in.update(checked_in_at: Time.current)
        @event_user = existing_check_in
      else
        @event_user = EventUser.create!(
          event_id: @event.id,
          user_id: @user&.id,
          event_guest_id: event_guest&.id,
          checked_in_at: Time.current,
          rsvp: 'attended'
        )
      end

      render json: {
        success: true,
        message: 'Successfully checked in',
        member: {
          id: @user&.id,
          user_type: @user&.user_type,
          email: @user&.email,
          firstname: @user&.firstname,
          lastname: @user&.lastname,
          date_of_birth: @user&.birth_date,
          api_key: @user&.api_key,
          selected_site_id: @user&.current_site_id,
          mobile: @user&.mobile,
          rotary_club: @user&.rotary_club,
          wedding_date: @user&.wedding_date,
          business_name: @user&.business_name,
          business_category: @user&.business_category,
          education_qualification: @user&.education_qualification,
          resident_address: @user&.user_address,
          office_address: @user&.office_address,
          facebook: @user&.facebook_link,
          instagram: @user&.instagram_link,
          linkedin_profile: @user&.linkedin_profile,
          date_of_joining: @user&.date_of_joining,
          blood_group: @user&.blood_group
        }
      }

    rescue => e
      Rails.logger.error "Check-in Error: #{e.message}"
      render json: { success: false, message: 'Something went wrong.' }, status: :internal_server_error
    end

  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: 'Event not found' }, status: :not_found
  end


  private

  # Check if a date is 2nd or 4th Saturday of the month
  # def second_or_fourth_saturday?(date)
  #   return false unless date.friday? || date.saturday?

  #   day = date.day
  #   (8..14).include?(day) || (22..28).include?(day)
  # end
  def second_or_fourth_friday_or_saturday?(date)
    weekday = date.wday # 5 = Friday, 6 = Saturday
    day = date.day

    is_friday_or_saturday = [5, 6].include?(weekday)
    week_of_month = (day - 1) / 7 + 1

    is_friday_or_saturday && (week_of_month == 2 || week_of_month == 4)
  end



  def check_otp
    @event = Event.find(params[:id])

    site_id = @event.site_id

    user_ids = UserSite.where(site_id: site_id).pluck(:user_id)

    @user = User.where(id: user_ids).find_by(mobile: params[:mobile])

    if !@user.present?
      # @event_user = @event.event_users.create(user_id: @user.id)
      # else
      @user = EventGuest.find_by(mobile: params[:mobile])
      #@event_user = @event.event_users.create(event_guest_id: event_guest.id)

    end

    if @user
      begin
        otp = rand(100000..999999)
        @user.update!(otp: otp, updated_at: Time.current)
        var = "_"
        sms_message = "Dear #{@user.fullname},

Please complete your visit request using the One-Time Password #{otp}.
Alternatively, you can scan the QR code below to quickly complete the verification process.

QR Link - #{var}

Thank You!

Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"
        encoded_message = CGI.escape(sms_message)
        sms_url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{@user.mobile}&source=VBCONN&message=#{encoded_message}&entityid=1201173433382664591&tempid=1207173989279594259")

        http = Net::HTTP.new(sms_url.host, sms_url.port)
        request = Net::HTTP::Get.new(sms_url)
        response = http.request(request)
        puts "#{response.body}"
        # Log response (for debugging)
        Rails.logger.info "SMS API Response: #{response.body}"

      rescue StandardError => e

      end
      # Update check-in status and time
      #@event_user.update(checked_in_at: Time.current, rsvp: 'attended')
      render json: { success: true, message: 'Successfully Sent Otp on Mobile No.' }
    else
      render json: { success: false, message: 'User not registered!' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: 'Event not found' }, status: :not_found
  end

end
