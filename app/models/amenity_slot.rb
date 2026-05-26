class AmenitySlot < ApplicationRecord
  def slot_str
    self.start_hr.to_s + ":" + self.start_min.to_s + " to " + self.end_hr.to_s + ":" + self.end_min.to_s
  end

  def twelve_hr_slot
    return "" if start_hr.blank? || end_hr.blank?
    start_time = Time.new(2000, 1, 1, start_hr, start_min || 0)
    end_time   = Time.new(2000, 1, 1, end_hr, end_min || 0)
    "#{start_time.strftime('%I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
  end
end
