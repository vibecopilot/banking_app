class VisitorDeviceLog < ApplicationRecord
  validates :employee_no, presence: true
  validates :in_time, presence: true
  validates :door_no, presence: true
    # Custom validation for out_time
  validate :out_time_after_in_time
  validates :employee_no, uniqueness: { scope: [:in_time, :out_time], message: "Duplicate log entry for the same time range" }

  private

  def out_time_after_in_time
    if out_time.present? && in_time.present? && out_time <= in_time
      errors.add(:out_time, "must be after in_time")
    end
  end
end
