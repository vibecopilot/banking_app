class VisitorGroupInviteJob < ApplicationJob
  queue_as :default

  def perform(visitor_group_invite_id)
    group_invite = VisitorGroupInvite.includes(:site, :invited_by, :visitor_group_invite_guests)
                                     .find_by(id: visitor_group_invite_id)
    return unless group_invite
    
    invited_guests = group_invite.visitor_group_invite_guests.where(status: 'invited')
    
    invited_guests.each do |guest|
      send_sms_invitation(guest, group_invite)
    end
  end
  
  private
  
  def send_sms_invitation(guest, group_invite)
    # Build registration link
    host = Rails.application.config.action_mailer.default_url_options&.dig(:host) || 'localhost'
    port = Rails.application.config.action_mailer.default_url_options&.dig(:port)
    protocol = Rails.env.production? ? 'https' : 'http'
    
    registration_url = Rails.application.routes.url_helpers.guest_register_visitor_group_invites_url(
      token: guest.invitation_token,
      host: host,
      port: port,
      protocol: protocol
    )
    
    # SMS message template with inviter's name
    invited_by_name = group_invite.invited_by.full_name
    message = "#{invited_by_name} has invited you! "\
              "Register as visitor here: #{registration_url}"
    
    # Send SMS
    send_sms(guest.mobile_number, message, group_invite.site.company_id)
    
    Rails.logger.info "[SMS] Sent group invite to #{guest.mobile_number} from #{invited_by_name}"
  end
  
  def send_sms(mobile_number, message, company_id)
    # Integrate with your SMS gateway
    begin
      Rails.logger.info "[SMS] Sending to: #{mobile_number}, Message: #{message}"
      
      # Add your SMS gateway implementation here
      # Example for MSG91, Twilio, etc.
      
    rescue => e
      Rails.logger.error "[SMS] Failed to send: #{e.message}"
    end
  end
end
