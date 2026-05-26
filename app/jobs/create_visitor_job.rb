class CreateVisitorJob < ApplicationJob
  queue_as :default

  def perform(visitor_id, visitor_files, current_host)
    visitor = Visitor.find_by(id: visitor_id)
    return unless visitor

    # Attach visitor files
    if visitor_files.present?
      visitor_files.each do |doc|
        Attachfile.create(image: doc, relation: "VisitorFile", relation_id: visitor.id, active: 1)
      end
    end

    # Attach profile picture
 

    # Create associated records
    # create_associated_records(visitor)

    # Send OTP
    send_otp(visitor, current_host)
  end
  private

  def create_associated_records(visitor)
    if visitor.vhost_id.present?
      user = User.find_by(id: visitor.vhost_id)
      if user
        host_params = {
          visitor_id: visitor.id,
          user_id: user.id,
          is_approved: visitor.skip_host_approval || (visitor.created_by_id == user.id) ? true : nil,
          updated_at: visitor.skip_host_approval ? Time.current : nil
        }
        Host.create(host_params)
      end
    end
    VisitorVisit.create(visitor_id: visitor.id, check_in: nil, check_out: nil)
  end

  # puts "Host: #{request.host}"

  def send_otp(visitor, current_host)
    otp = generate_otp
    visitor.update(otp: otp)

    # Dynamic Host
      web_url = case current_host
              when "app.myciti.life"
                "https://myciti.life/otp-qr?v=#{visitor.id} "
              when "admin.vibecopilot.ai"
                "https://app.vibecopilot.ai/otp-qr?v=#{visitor.id}  "
              else
                "" 
              end


    # # for multiple servers
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
when "localhost:3000"
  "Dear #{visitor.name},

You've been registered as a visitor on the Bhoomi Celestia site. Your OTP to visit is #{otp}. You can access your digital gate pass from this URL - #{web_url}

Powered by DIGIELVES TECH WIZARDS PRIVATE LIMITED"
else
  ""
end



    begin
      if current_host == "app.myciti.life"
          url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{visitor.contact_no}&source=VBCONN&message=#{message}&entityid=1201173433382664591&tempid=1207173989279594259")
      elsif current_host == "admin.vibecopilot.ai"
          url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{visitor.contact_no}&source=VBCONN&message=#{message}&entityid=1201173433382664591&tempid=1207173989279594259")
         else current_host == "localhost:3000"
          url = URI("http://sms6.rmlconnect.net:8080/bulksms/bulksms?username=VCSMST&password=%5BPdjH9-6&type=0&dlr=1&destination=#{visitor.contact_no}&source=MCITIL&message=#{message}&entityid=1201173433382664591&tempid=1207174876323712614")
    end
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      response = http.request(request)
      Rails.logger.info "SMS Response: #{response.read_body}"
    rescue StandardError => e
      Rails.logger.error "Failed to send OTP: #{e.message}"
    end
  end

  def generate_otp
    rand(10000..99999).to_s
  end
end
