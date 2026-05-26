class ServiceSubcategory < ApplicationRecord
  belongs_to :service_category
  belongs_to :site
  has_many :service_slots, dependent: :destroy
  has_many :service_pricings, dependent: :destroy
  has_many :service_bookings, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :service_category_id }
  validates :duration_minutes, :advance_booking_hours, :cancellation_hours, 
            presence: true, numericality: { greater_than: 0 }
  validates :sort_order, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :for_site, ->(site_id) { where(site_id: site_id) }
  scope :for_category, ->(category_id) { where(service_category_id: category_id) }
  scope :ordered, -> { order(:sort_order, :name) }

  def available_slots_for_date(date)
    # Get all slots for this subcategory
    all_slots = service_slots.active.order(:start_time)
    
    # Get existing bookings for the date
    existing_bookings = service_bookings
                       .where(booking_date: date)
                       .where.not(status: ['cancelled'])
                       .group(:service_slot_id)
                       .count

    # Filter slots based on max_bookings
    all_slots.select do |slot|
      booked_count = existing_bookings[slot.id] || 0
      booked_count < slot.max_bookings
    end
  end

  def price_for_unit_configuration(unit_config_id)
    service_pricings.active.find_by(unit_configuration_id: unit_config_id)
  end

  def duration_in_hours
    duration_minutes / 60.0
  end

  def can_book_for_date?(date)
    return false if date <= Date.current
    
    hours_difference = ((date.beginning_of_day - Time.current) / 1.hour).round
    hours_difference >= advance_booking_hours
  end

  def can_cancel_booking?(booking_date, slot_start_time)
    booking_datetime = booking_date.beginning_of_day + slot_start_time.seconds_since_midnight.seconds
    hours_difference = ((booking_datetime - Time.current) / 1.hour).round
    hours_difference >= cancellation_hours
  end
end
