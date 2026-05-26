class RoomBooking < ApplicationRecord
  belongs_to :room
  belongs_to :user
  belongs_to :site

  validates :check_in_date, presence: true
  validates :check_out_date, presence: true
  validates :number_of_adults, presence: true, numericality: { greater_than: 0 }
  validates :number_of_children, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :guest_name, presence: true
  validates :guest_phone, presence: true
  validates :subtotal_amount, presence: true, numericality: { greater_than: 0 }
  validates :tax_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  validate :check_out_after_check_in
  validate :room_capacity_not_exceeded
  validate :room_available_for_dates
  validate :future_booking_date

  enum status: { 
    pending: 0, 
    confirmed: 1, 
    checked_in: 2, 
    checked_out: 3, 
    cancelled: 4,
    no_show: 5
  }

  enum payment_status: {
    unpaid: 0,
    partial: 1,
    paid: 2,
    refunded: 3
  }

  scope :active, -> { where.not(status: ['cancelled']) }
  scope :current, -> { where(status: ['confirmed', 'checked_in']) }
  scope :by_site, ->(site_id) { where(site_id: site_id) }
  scope :by_date_range, ->(start_date, end_date) {
    where('check_in_date <= ? AND check_out_date >= ?', end_date, start_date)
  }

  before_validation :calculate_amounts, if: :booking_details_changed?
  before_validation :set_site_from_room

  def duration_nights
    (check_out_date - check_in_date).to_i
  end

  def guest_count
    number_of_adults + number_of_children
  end

  def can_check_in?
    confirmed? && Date.current >= check_in_date && Date.current <= check_out_date
  end

  def can_check_out?
    checked_in? && Date.current <= check_out_date
  end

  def can_cancel?
    pending? || confirmed?
  end

  def is_overdue?
    confirmed? && Date.current > check_out_date
  end

  def check_in!
    return false unless can_check_in?
    
    update!(
      status: 'checked_in',
      actual_check_in_time: Time.current
    )
  end

  def check_out!
    return false unless can_check_out?
    
    update!(
      status: 'checked_out',
      actual_check_out_time: Time.current
    )
  end

  def cancel!(reason = nil)
    return false unless can_cancel?
    
    update!(
      status: 'cancelled',
      cancellation_reason: reason,
      cancelled_at: Time.current
    )
  end

  def booking_reference
    "RB#{id.to_s.rjust(6, '0')}"
  end

  def display_dates
    "#{check_in_date.strftime('%d %b %Y')} - #{check_out_date.strftime('%d %b %Y')}"
  end

  private

  def check_out_after_check_in
    return unless check_in_date && check_out_date
    
    if check_out_date <= check_in_date
      errors.add(:check_out_date, 'must be after check-in date')
    end
  end

  def room_capacity_not_exceeded
    return unless room && number_of_adults && number_of_children
    
    if number_of_adults > room.max_adults
      errors.add(:number_of_adults, "cannot exceed room capacity of #{room.max_adults}")
    end
    
    if number_of_children > room.max_children
      errors.add(:number_of_children, "cannot exceed room capacity of #{room.max_children}")
    end
  end

  def room_available_for_dates
    return unless room && check_in_date && check_out_date && !cancelled?
    
    # Skip validation if this is an update and dates haven't changed
    return if persisted? && !check_in_date_changed? && !check_out_date_changed?
    
    unless room.available_on_dates?(check_in_date, check_out_date)
      errors.add(:base, 'Room is not available for the selected dates')
    end
  end

  def future_booking_date
    return unless check_in_date
    
    if check_in_date < Date.current
      errors.add(:check_in_date, 'cannot be in the past')
    end
  end

  def booking_details_changed?
    check_in_date_changed? || check_out_date_changed? || room_id_changed?
  end

  def calculate_amounts
    return unless room && check_in_date && check_out_date
    
    self.subtotal_amount = room.total_price_for_stay(check_in_date, check_out_date)
    self.tax_amount = room.tax_amount_for_stay(check_in_date, check_out_date)
    self.total_amount = subtotal_amount + tax_amount
  end

  def set_site_from_room
    self.site_id = room.site_id if room
  end
end
