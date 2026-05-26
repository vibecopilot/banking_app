if defined?(RailsPushNotifications::Notification)
  RailsPushNotifications::Notification.class_eval do
    after_create :add_job

    def add_job
      PushNotificationJob.set(wait_until: Time.zone.now + 1.seconds).perform_later(self)
    end
  end
end
