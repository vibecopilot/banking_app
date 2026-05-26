class AminitySetup < ApplicationRecord
  has_many :aminity_bookings, foreign_key: :aminity_id, primary_key: :aminity_id
  has_many :amenity_slots, foreign_key: :amenity_id, primary_key: :aminity_id
  
  validates :max_bookings_per_week, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :concurrent_slot, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :slot_by, inclusion: { in: AmenitySlotGenerator::VALID_SLOT_DURATIONS }, allow_nil: true
  validates :wrap_time, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def bookings_this_week(date = Date.today)
    start_of_week = date.beginning_of_week
    end_of_week = date.end_of_week
    
    aminity_bookings.where(date: start_of_week..end_of_week).count
  end

  def bookings_remaining_this_week(date = Date.today)
    return nil if max_bookings_per_week.nil?
    max_bookings_per_week - bookings_this_week(date)
  end

  def can_book_this_week?(date = Date.today)
    return true if max_bookings_per_week.nil?
    bookings_remaining_this_week(date) > 0
  end

  def generate_slots!
    AmenitySlotGenerator.new(self).generate_slots
  end
end