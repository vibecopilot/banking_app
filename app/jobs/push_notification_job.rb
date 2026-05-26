class PushNotificationJob < ActiveJob::Base
  queue_as :pushnotfn
  self.queue_adapter = :sidekiq

  def perform(notification)
    app = notification.app
    pusher = app.send(:build_pusher)
    to_send = app.send(:notification_type).new notification.destinations, notification.data
    pusher.push [to_send]
    notification.update_attributes! results: to_send.results
  end
end