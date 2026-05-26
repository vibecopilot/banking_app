class Attendance < ApplicationRecord
  validates :attendance_of_id, :attendance_of_type, presence: true
  belongs_to :attendance_of, polymorphic: true
  belongs_to :user, class_name: 'User', foreign_key: :attendance_of_id, optional: true
  belongs_to :staff, class_name: "Staff", foreign_key: :attendance_of_id, optional: true
  belongs_to :resource, polymorphic: true

  after_commit :notify_staff_entry, on: :create, if: -> {attendance_of_type == 'Staff' && punched_in_at.present?}
  after_commit :notify_staff_exit, on: :update, if: -> {attendance_of_type == 'Staff' && saved_change_to_punched_out_at? && punched_out_at.present?}

  def notify_staff_entry
    StaffEntryNotificationJob.perform_later(attendance_of_id, 'entry')
  end

  def notify_staff_exit
    StaffEntryNotificationJob.perform_later(attendance_of_id, 'exit')
  end
  def user_name
    user.try(:full_name)
  end

  class << self

    def attendance_for(date, user_id)
      attendance = Attendance.where("DATE(punched_in_at) = ?", date).find_by(attendance_of_id: user_id)
      if attendance.present?
        {InTime: attendance.punched_in_time, OutTime: attendance.punched_out_time, Duration: attendance.duration}
      else
        {Duration: '00:00'}
      end
    end

    def present_days(user_id, month)
      Attendance.where(attendance_of_id: user_id).where("MONTH(punched_in_at) = ? OR MONTH(punched_out_at) =? ", month, month).count
    end

  end

  def previous_punched_in_time
    user.attendances.find_by('DATE(punched_in_at) =? ', Date.yesterday).try(:punched_in_at)
  end

  def previous_punched_out_time
    user.attendances.find_by('DATE(punched_out_at) =? ', Date.yesterday).try(:punched_out_at)
  end

  def previous_attendace_id
    user.attendances.find_by('DATE(punched_in_at) =? ', Date.yesterday).try(:id)
  end

  def punched_in_time
    punched_in_at.try(:strftime, "%H:%M")
  end

  def punched_out_time
    punched_out_at.try(:strftime, "%H:%M")
  end

  def formatted_date
    punched_in_at.present? ? punched_in_at.try(:strftime, "%d/%m/%Y") : punched_out_at.try(:strftime, "%d/%m/%Y")
  end

  def formatted_day
    punched_in_at.present? ? punched_in_at.try(:strftime, "%A") : punched_out_at.try(:strftime, "%A")
  end

  def duration
    if punched_in_at.present? && punched_out_at.present?
      diff = punched_out_at - punched_in_at
      Time.at(diff.round).utc.strftime("%H:%M")
    else
      '00:00'
    end
  end

end
