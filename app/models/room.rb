class Room < ApplicationRecord
  belongs_to :site
  has_many :room_bookings, dependent: :destroy
  has_many :room_pricing, dependent: :destroy
  has_many :room_availability, dependent: :destroy

  validates :name, presence: true
  validates :room_number, presence: true, uniqueness: { scope: :site_id }
  validates :room_type, presence: true
  validates :base_price_per_night, presence: true, numericality: { greater_than: 0 }
  validates :max_adults, presence: true, numericality: { greater_than: 0 }
  validates :max_children, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :floor_number, numericality: { greater_than: 0 }, allow_blank: true

  enum status: { available: 0, occupied: 1, maintenance: 2, out_of_order: 3 }
  enum room_type: { standard: 0, deluxe: 1, suite: 2, premium: 3, penthouse: 4 }

  scope :active, -> { where(active: true) }
  scope :by_site, ->(site_id) { where(site_id: site_id) }
  scope :available_for_dates, ->(check_in, check_out) {
    where.not(
      id: RoomBooking.joins(:room)
                     .where(
                       status: ['confirmed', 'checked_in'],
                       check_in_date: check_in..check_out,
                       check_out_date: check_in..check_out
                     )
                     .select(:room_id)
    )
  }

  def available_on_dates?(check_in_date, check_out_date)
    return false unless active? && available?
    
    # Check for conflicting bookings
    conflicting_bookings = room_bookings.where(
      status: ['confirmed', 'checked_in'],
      check_in_date: check_in_date..check_out_date,
      check_out_date: check_in_date..check_out_date
    )
    
    # Check room availability restrictions
    blocked_dates = room_availability.where(
      date: check_in_date..check_out_date,
      available: false
    )
    
    conflicting_bookings.empty? && blocked_dates.empty?
  end

  def price_for_date(date)
    # Check for specific pricing for this date
    specific_pricing = room_pricing.where(
      'start_date <= ? AND end_date >= ?', date, date
    ).order(created_at: :desc).first
    
    return specific_pricing.price_per_night if specific_pricing
    
    base_price_per_night
  end

  def total_price_for_stay(check_in_date, check_out_date)
    total = 0
    (check_in_date...check_out_date).each do |date|
      total += price_for_date(date)
    end
    total
  end

  def tax_amount_for_stay(check_in_date, check_out_date)
    subtotal = total_price_for_stay(check_in_date, check_out_date)
    (subtotal * tax_percentage / 100).round(2)
  end

  def total_with_tax_for_stay(check_in_date, check_out_date)
    subtotal = total_price_for_stay(check_in_date, check_out_date)
    tax = tax_amount_for_stay(check_in_date, check_out_date)
    subtotal + tax
  end

  def display_name
    "#{name} (#{room_number})"
  end

  def capacity
    "#{max_adults} Adults, #{max_children} Children"
  end
end
