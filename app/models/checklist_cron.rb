# class ChecklistCron < ApplicationRecord
#   after_update :after_update_cron


#     def after_update_cron
#     at = Activity.where(checklist_id: self.checklist_id)
#     last_act = at.last
#     tasks = at.where(status: ["upcoming", nil, "open", "pending"]).pluck(:id)
#     batch_size = 1000
#     tasks.each_slice(batch_size) do |batch|
#         Activity.where(id: batch).delete_all
#       end
#         ChecklistSchedulingJob.set(wait_until: Time.zone.now + 1.minute).perform_later(self.id,last_act)
#   end


#   def create_activities(last_act)
#     if self.checklist.present?
#       for i in 0..Float::INFINITY
#         scht = scht || self.checklist.start_date
#         scht = sch.next(scht)
#         break if (checklist.end_date < scht)
#         next if scht <= Time.zone.now
#             activity = Activity.new(
#               checklist_id: self.checklist_id,
#               start_time: scht,
#               status: "scheduled",
#               asset_id: last_act&.asset_id,
#               soft_service_id: last_act&.soft_service_id
#             )
#             activity.save
#       end
#     end
#   end
# end

require 'fugit'

class ChecklistCron < ApplicationRecord
  belongs_to :checklist, foreign_key: 'checklist_id', class_name: "Checklist", optional: true
  after_update :after_update_cron

  def after_update_cron
    activities = Activity.where(checklist_id: self.checklist_id)

    last_asset_activities = activities.where.not(asset_id: nil).pluck(:asset_id).uniq
    last_service_activities = activities.where.not(soft_service_id: nil).pluck(:soft_service_id).uniq
    # tasks = activities.where(status: ["upcoming", nil, "open", "pending"]).pluck(:id)
    tasks = activities.where("start_time >= ?", Date.today.beginning_of_day).pluck(:id)
    batch_size = 1000
    tasks.each_slice(batch_size) { |batch| Activity.where(id: batch).delete_all }
    # ChecklistSchedulingJob.set(wait_until: Time.zone.now + 1.minute).perform_later(self.id, last_asset_activities, last_service_activities)
    self.create_activities(last_asset_activities, last_service_activities)
  end

  # def create_activities(last_asset_activities, last_service_activities)
  #   return unless self.checklist_id.present?
  #   cron_parser = Fugit.parse(self.expression)
  #   last_asset_activities.each do |asset_id|
  #     schedule_activities(asset_id, nil, cron_parser)
  #   end

  #   last_service_activities.each do |soft_service_id|
  #     schedule_activities(nil, soft_service_id, cron_parser)
  #   end
  # end

  def create_activities(last_asset_activities, last_service_activities)
    return unless self.checklist_id.present?
    cron_parser = Fugit.parse(self.expression)

    start_time = self.checklist.start_date.to_time
    end_time = self.checklist.end_date.to_time

    # Collect timings in advance
    timings = []
    next_time = cron_parser.next_time(start_time).to_t
    while next_time && next_time <= end_time
      timings << next_time
      next_time = cron_parser.next_time(next_time).to_t
    end

    asset_activities = []
    last_asset_activities.each do |asset_id|
      timings.each do |scht|
        next if scht <= Time.zone.now # Only future
        asset_activities << {
          checklist_id: self.checklist_id,
          start_time: scht,
          status: "scheduled",
          asset_id: asset_id,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      end
    end

    service_activities = []
    last_service_activities.each do |soft_service_id|
      timings.each do |scht|
        next if scht <= Time.zone.now # Only future
        service_activities << {
          checklist_id: self.checklist_id,
          start_time: scht,
          status: "scheduled",
          soft_service_id: soft_service_id,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      end
    end

    # Bulk insert in transaction
    ActiveRecord::Base.transaction do
      if asset_activities.any?
        if Activity.respond_to?(:insert_all)
          Activity.insert_all(asset_activities)
        else
          asset_activities.each { |attrs| Activity.create!(attrs) }
        end
      end
      
      if service_activities.any?
        if Activity.respond_to?(:insert_all)
          Activity.insert_all(service_activities)
        else
          service_activities.each { |attrs| Activity.create!(attrs) }
        end
      end
    end
  end


  private

  def schedule_activities(asset_id, soft_service_id, cron_parser)
    scht = self.checklist.start_date.to_time

    loop do
      scht = cron_parser.next_time(scht).to_t
      break if self.checklist.end_date.to_time < scht
      next if scht <= Time.zone.now

      Activity.create!(
        checklist_id: self.checklist_id,
        start_time: scht,
        status: "scheduled",
        asset_id: asset_id,
        soft_service_id: soft_service_id
      )
    end
  end
end
