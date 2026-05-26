# app/jobs/cron_scheduling_job.rb
class CronSchedulingJob < ApplicationJob
  queue_as :default

  def perform(cron_setting_id)
    cron_setting = CronSetting.find_by(id: cron_setting_id)
    return unless cron_setting

    activity = cron_setting.activity
    return unless activity

    schedule_recurring_activities(activity, cron_setting)
  end

  private

  def schedule_recurring_activities(activity, cron_setting)
    end_date = calculate_end_date(activity, cron_setting)
    current_date = activity.start_time.to_date

    while current_date <= end_date
      schedule_for_date(activity, cron_setting, current_date) if cron_setting.matches?(current_date)
      current_date += 1.day
    end
  end

  def calculate_end_date(activity, cron_setting)
    case cron_setting.recurrence_type
    when 'yearly'
      activity.start_time.advance(years: cron_setting.year_interval)
    else
      activity.start_time.advance(years: 1) # Default to one year for other recurrence types
    end
  end

  def schedule_for_date(activity, cron_setting, date)
    start_datetime = date.change(hour: cron_setting.start_hour, min: cron_setting.start_minute)
    end_datetime = date.change(hour: cron_setting.end_hour, min: cron_setting.end_minute)
    
    # Adjust end_datetime if it's before start_datetime (crosses midnight)
    end_datetime += 1.day if end_datetime < start_datetime

    Activity.create!(
      asset_id: activity.asset_id,
      checklist_id: activity.checklist_id,
      soft_service_id: activity.soft_service_id,
      patrolling_id: activity.patrolling_id,
      assigned_to: activity.assigned_to,
      start_time: start_datetime,
      end_time: end_datetime,
      status: 'pending'
    )
  end
end