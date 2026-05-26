class ServiceSlot < ApplicationRecord
  belongs_to :service_subcategory
  has_many :service_bookings, dependent: :destroy

  # Validation for new hour/minute fields
  validates :start_hr, :end_hr, :start_min, :end_min, presence: true
  validates :start_hr, :end_hr, numericality: { in: 0..23 }
  validates :start_min, :end_min, numericality: { in: 0..59 }
  validates :max_bookings, presence: true, numericality: { greater_than: 0 }
  validate :end_time_after_start_time
  # validate :unique_time_slot

  # Set default values before validation if hour/minute fields are not set but time fields are
  before_validation :set_hour_minute_from_time_fields

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:start_hr, :start_min) }

def display_time
  return "" if start_hr.nil? || start_min.nil? || end_hr.nil? || end_min.nil?

  start_time_str = format("%02d:%02d", start_hr, start_min)
  end_time_str = format("%02d:%02d", end_hr, end_min)

  start_12hr = Time.parse(start_time_str).strftime('%I:%M %p')
  end_12hr = Time.parse(end_time_str).strftime('%I:%M %p')

  "#{start_12hr} - #{end_12hr}"
rescue => e
  Rails.logger.error "display_time error: #{e.message}"
  ""
end

  def slot_str
    "#{start_hr}:#{start_min} to #{end_hr}:#{end_min}"
  end

  # Helper methods for compatibility with existing code
  # def start_time
  #   Time.parse(sprintf("%02d:%02d", start_hr, start_min))
  # end

  # def end_time
  #   Time.parse(sprintf("%02d:%02d", end_hr, end_min))
  # end

  def available_on_date?(date)
    return false unless active?
    
    booked_count = service_bookings
                  .where(booking_date: date)
                  .where.not(status: ['cancelled'])
                  .count
    
    booked_count < max_bookings
  end

  def bookings_count_for_date(date)
    service_bookings
      .where(booking_date: date)
      .where.not(status: ['cancelled'])
      .count
  end

  def available_spots_for_date(date)
    max_bookings - bookings_count_for_date(date)
  end

  private

  def set_hour_minute_from_time_fields
    # If hour/minute fields are not set but time fields are, convert them
    if start_hr.blank? && start_time.present?
      self.start_hr = start_time.hour
      self.start_min = start_time.min
    end
    
    if end_hr.blank? && end_time.present?
      self.end_hr = end_time.hour
      self.end_min = end_time.min
    end
    
    # Also set the time fields from hour/minute for backward compatibility
    if start_hr.present? && start_min.present?
      time_str = sprintf("%02d:%02d", start_hr, start_min)
      self.start_time = Time.parse(time_str) rescue nil
    end
    
    if end_hr.present? && end_min.present?
      time_str = sprintf("%02d:%02d", end_hr, end_min)
      self.end_time = Time.parse(time_str) rescue nil
    end
  end

  def end_time_after_start_time
    return unless start_hr && end_hr && start_min && end_min
    
    start_total_minutes = start_hr * 60 + start_min
    end_total_minutes = end_hr * 60 + end_min
    
    # Handle overnight slots (e.g., 23:30 to 01:30)
    if end_total_minutes <= start_total_minutes
      end_total_minutes += 24 * 60
    end
    
    errors.add(:end_time, "must be after start time") if end_total_minutes <= start_total_minutes
  end

  def unique_time_slot
    return unless start_hr && start_min && service_subcategory_id
    
    existing_slot = ServiceSlot.where(
      service_subcategory_id: service_subcategory_id,
      start_hr: start_hr,
      start_min: start_min
    ).where.not(id: id).first
    
    errors.add(:start_time, "slot already exists for this time") if existing_slot
  end
end
