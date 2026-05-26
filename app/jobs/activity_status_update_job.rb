class ActivityStatusUpdateJob < ApplicationJob
  queue_as :default

  def perform
    Activity.update_status
  end
end
