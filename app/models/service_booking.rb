class ServiceBooking < ApplicationRecord
  belongs_to :user
  belongs_to :unit
  belongs_to :service_subcategory, optional: true
  belongs_to :service_slot, optional: true
  belongs_to :service_pricing, optional: true
  belongs_to :unit_configuration, optional: true

  validates :booking_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed in_progress completed cancelled] }
  validates :payment_status, inclusion: { in: %w[pending paid failed refunded] }
  validates :total_amount, :final_amount, presence: true, numericality: { greater_than: 0 }
  validates :rating, numericality: { in: 1..5 }, allow_blank: true
  # validate :booking_date_not_in_past
  # validate :slot_available_for_date
  # validate :advance_booking_validation
  # validate :duplicate_booking_check

  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_date, ->(date) { where(booking_date: date) }
  scope :active, -> { where.not(status: 'cancelled') }
  scope :completed, -> { where(status: 'completed') }
  # scope :upcoming, -> { where('booking_date >= ?', Date.current) }
  # scope :past, -> { where('booking_date < ?', Date.current) }

  before_validation :calculate_amounts, on: [:create, :update]
  after_create :send_booking_confirmation
  after_update :send_status_update, if: :saved_change_to_status?
  before_save :set_status_after_payment

  def can_be_cancelled?
    return false if status == 'cancelled'
    return false if status == 'completed'

    service_subcategory.can_cancel_booking?(booking_date, service_slot.start_time)
  end

  def cancel_booking!(reason = nil)
    return false unless can_be_cancelled?

    self.status = 'cancelled'
    self.cancellation_reason = reason
    self.cancelled_at = Time.current
    save
  end

  def display_status
    status.humanize
  end

  def display_time_slot
    service_slot.display_time
  end

  def service_date_time
    booking_date.beginning_of_day + service_slot.start_time.seconds_since_midnight.seconds
  end

  def is_upcoming?
    booking_date >= Date.current && status != 'cancelled'
  end

  def is_past?
    booking_date < Date.current
  end

  def can_rate?
    status == 'completed' && rating.blank?
  end

  def total_duration
    return nil unless service_started_at && service_completed_at
    
    ((service_completed_at - service_started_at) / 1.minute).round
  end

  private

  def calculate_amounts
    return unless service_pricing
    
    pricing = service_pricing.price_breakdown
    self.total_amount = pricing[:original_price]
    self.discount_amount = pricing[:discount_amount]
    self.tax_amount = pricing[:tax_amount]
    self.final_amount = pricing[:final_price]
  end

  def booking_date_not_in_past
    return unless booking_date
    
    errors.add(:booking_date, "cannot be in the past") if booking_date < Date.current
  end

  def slot_available_for_date
    return unless service_slot && booking_date
    
    unless service_slot.available_on_date?(booking_date)
      errors.add(:service_slot, "is not available for the selected date")
    end
  end

  def advance_booking_validation
    return unless service_subcategory && booking_date
    
    unless service_subcategory.can_book_for_date?(booking_date)
      hours_required = service_subcategory.advance_booking_hours
      errors.add(:booking_date, "must be at least #{hours_required} hours in advance")
    end
  end


  def set_status_after_payment
  if payment_status_changed? && payment_status == "paid"
    self.status = "confirmed" if status == "pending"
  end
end

  def duplicate_booking_check
    return unless user && service_subcategory && service_slot && booking_date
    
    existing_booking = ServiceBooking.where(
      user: user,
      service_subcategory: service_subcategory,
      service_slot: service_slot,
      booking_date: booking_date,
      status: ['pending', 'confirmed', 'in_progress']
    ).where.not(id: id).first
    
    if existing_booking
      errors.add(:base, "You already have a booking for this service at this time")
    end
  end

  def send_booking_confirmation
    # Add email/SMS notification logic here
    Rails.logger.info "Booking confirmation sent for booking ##{id}"
  end

  def send_status_update
    # Add email/SMS notification logic here
    Rails.logger.info "Status update sent for booking ##{id}: #{status}"
  end
end
