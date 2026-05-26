class EventGuestInvitationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.includes(:site, :event_guests).find_by(id: event_id)
    return unless event
    
    event.event_guests.where(status: 'invited').each do |guest|
      send_sms_invitation(guest, event)
    end
  end
  
  private
  
  def send_sms_invitation(guest, event)
    # Build registration link
    host = Rails.application.config.action_mailer.default_url_options&.dig(:host) || 'localhost'
    port = Rails.application.config.action_mailer.default_url_options&.dig(:port)
    protocol = Rails.env.production? ? 'https' : 'http'
    
    registration_url = Rails.application.routes.url_helpers.register_event_guest_url(
      token: guest.invitation_token,
      host: host,
      port: port,
      protocol: protocol
    )
    
    # SMS message template
    message = "You're invited to #{event.title}! "\
              "Date: #{event.start_date_time.strftime('%d %b %Y %I:%M %p')} "\
              "Location: #{event.location}. "\
              "Register here: #{registration_url}"
    
    # Send SMS (using your SMS service)
    send_sms(guest.mobile_number, message, event.site.company_id)
    
    Rails.logger.info "[SMS] Sent invitation to #{guest.mobile_number} for event #{event.id}"
  end
  
  def send_sms(mobile_number, message, company_id)
    # Integrate with your SMS gateway (e.g., Twilio, MSG91, etc.)
    # Example for MSG91:
    begin
      sms_api_url = "https://api.msg91.com/api/v5/flow/"
      # Replace with your actual SMS gateway implementation
      Rails.logger.info "[SMS] Sending to: #{mobile_number}, Message: #{message}"
      
      # Example HTTP request (adjust based on your SMS provider)
      # uri = URI(sms_api_url)
      # response = Net::HTTP.post_form(uri, {
      #   'authkey' => ENV['SMS_API_KEY'],
      #   'mobiles' => mobile_number,
      #   'message' => message,
      #   'sender' => 'SENDER_ID',
      #   'route' => '4'
      # })
      
    rescue => e
      Rails.logger.error "[SMS] Failed to send: #{e.message}"
    end
  end
end
