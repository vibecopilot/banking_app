class AmenitySetup < ApplicationRecord
  belongs_to :amenity, foreign_key: :amenity_id
  has_many :amenity_bookings, foreign_key: :amenity_id, primary_key: :amenity_id
  
  validates :max_bookings_per_week, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def bookings_this_week
    start_of_week = Date.today.beginning_of_week
    end_of_week = Date.today.end_of_week
    
    amenity_bookings.where(booking_date: start_of_week..end_of_week).count
  end

  def bookings_remaining_this_week
    return nil if max_bookings_per_week.nil?
    max_bookings_per_week - bookings_this_week
  end

  def can_book_this_week?
    return true if max_bookings_per_week.nil?
    bookings_remaining_this_week > 0
  end
end
