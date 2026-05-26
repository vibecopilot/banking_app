class RoomPricing < ApplicationRecord
  belongs_to :room

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :price_per_night, presence: true, numericality: { greater_than: 0 }
  validates :reason, presence: true

  validate :end_date_after_start_date
  validate :no_overlapping_pricing

  enum pricing_type: {
    seasonal: 0,
    promotional: 1,
    event_based: 2,
    weekend: 3,
    holiday: 4
  }

  scope :active, -> { where(active: true) }
  scope :for_date, ->(date) { where('start_date <= ? AND end_date >= ?', date, date) }
  scope :overlapping, ->(start_date, end_date) {
    where('start_date <= ? AND end_date >= ?', end_date, start_date)
  }

  def duration_days
    (end_date - start_date).to_i + 1
  end

  def covers_date?(date)
    date >= start_date && date <= end_date
  end

  def overlaps_with?(other_start_date, other_end_date)
    start_date <= other_end_date && end_date >= other_start_date
  end

  def display_period
    if start_date == end_date
      start_date.strftime('%d %b %Y')
    else
      "#{start_date.strftime('%d %b %Y')} - #{end_date.strftime('%d %b %Y')}"
    end
  end

  def price_difference
    return 0 unless room
    
    price_per_night - room.base_price_per_night
  end

  def price_difference_percentage
    return 0 unless room && room.base_price_per_night > 0
    
    ((price_difference / room.base_price_per_night) * 100).round(2)
  end

  def is_discount?
    price_difference < 0
  end

  def is_premium?
    price_difference > 0
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    
    if end_date < start_date
      errors.add(:end_date, 'must be after or same as start date')
    end
  end

  def no_overlapping_pricing
    return unless room && start_date && end_date
    
    overlapping_records = room.room_pricing
                             .where.not(id: id)
                             .active
                             .overlapping(start_date, end_date)
    
    if overlapping_records.exists?
      errors.add(:base, 'Pricing period overlaps with existing pricing')
    end
  end
end
