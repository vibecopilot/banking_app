set :output, "log/cron.log"
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every :day, at: '12:01am', roles: [:app] do
  runner "Activity.update_status"
end

# Check for overstaying visitors every 5 minutes
every 5.minutes, roles: [:app] do
  runner "VisitorOverstayAlertJob.perform_now"
end

# Calculate interest on overdue CAM bills daily at 1 AM
every :day, at: '1:00am', roles: [:app] do
  runner "CalculateInterestJob.perform_now"
end

# Refresh event statuses every 10 minutes
every 30.minutes, roles: [:app] do
  runner "Event.refresh_all_statuses"
end

every 1.day, at: '12:00 am' do
  runner "ActivityStatusUpdateJob.perform_later"
end

every 1.hour do 
  runner "Visitor.clear_expired_otps"
end
