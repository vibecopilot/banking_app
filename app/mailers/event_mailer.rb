class EventMailer < ApplicationMailer
  def event_notification(user, event)
    @user = user
    @event = event
    @tracking_pixel_url = track_email_open_event_url(@event, user_id: @user.id, host: default_url_host)
    @view_event_url = track_email_click_event_url(@event, user_id: @user.id, host: default_url_host)
    mail(to: @user.email, from: "noreply@vibecopilot.ai", subject: "New Event: #{@event.event_name}")
  end

  private

  def default_url_host
    Rails.application.config.action_mailer.default_url_options[:host] rescue 'myciti.life'
  end
end
