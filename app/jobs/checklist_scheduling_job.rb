# checklist_scheduling_job.rb
class ChecklistSchedulingJob < ActiveJob::Base
  queue_as :default
  self.queue_adapter = :sidekiq

  def perform(cron_id,last_asset_activities,last_service_activities)
    ChecklistCron.find_by_id(cron_id).create_activities(last_asset_activities,last_service_activities)
  end
end