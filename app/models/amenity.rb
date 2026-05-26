class Amenity < ApplicationRecord
  # Constants for valid payment methods
  PAYMENT_METHODS = %w[pay_on_facility complimentary].freeze
  has_many :amenity_slots, class_name: "AmenitySlot", foreign_key: "amenity_id"
  has_many :amenity_booking_rules, dependent: :destroy
  has_many :amenity_operational_days, dependent: :destroy
  accepts_nested_attributes_for :amenity_operational_days, allow_destroy: true
  accepts_nested_attributes_for :amenity_slots, allow_destroy: true
  accepts_nested_attributes_for :amenity_booking_rules, allow_destroy: true
  validate :validate_payment_methods

  has_many :attachments, -> { where(relation: "AmenityAttachmnet") }, :foreign_key => :relation_id, class_name: "Attachfile"
  has_many :cover_images, -> { where(relation: "AmenityCoverImage") }, :foreign_key => :relation_id, class_name: "Attachfile"
  has_many :aminity_setups, foreign_key: :aminity_id
  has_many :amenity_bookings, foreign_key: :amenity_id
  validates :concurrent_slot, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :slot_by, inclusion: { in: AmenitySlotGenerator::VALID_SLOT_DURATIONS }, allow_nil: true
  validates :wrap_time, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # has_many :amenity_slots, class_name: "AmenitySlot", foreign_key: "amenity_id"
  def setup
    aminity_setups.first
  end

  def bookings_this_week(date = Date.today)
    start_of_week = date.beginning_of_week
    end_of_week = date.end_of_week
    amenity_bookings.where(booking_date: start_of_week..end_of_week).count
  end

  def bookings_remaining_this_week(date = Date.today)
    return nil if setup.nil? || setup.max_bookings_per_week.nil?
    setup.max_bookings_per_week - bookings_this_week(date)
  end

  def can_book_this_week?(date = Date.today)
    return true if setup.nil? || setup.max_bookings_per_week.nil?
    bookings_remaining_this_week(date) > 0
  end

  def generate_slots!
    AmenitySlotGenerator.new(self).generate_slots
  end
    
# def self.convert_to_days_hours_and_minutes(total_minutes)
#   days = total_minutes / 1440          # 1440 minutes in a day
#   remaining_minutes = total_minutes % 1440
#   hours = remaining_minutes / 60       # Integer division gives hours
#   minutes = remaining_minutes % 60     # Remainder gives minutes
#   { days: days, hours: hours, minutes: minutes } # Return as a hash
# end

  # def self.convert_to_days_hours_and_minutes(total_minutes)
  #   days = total_minutes / 1440          # 1440 minutes in a day
  #   remaining_minutes = total_minutes % 1440
  #   hours = remaining_minutes / 60       # Integer division gives hours
  #   minutes = remaining_minutes % 60     # Remainder gives minutes
  #   { days: days, hours: hours, minutes: minutes } # Return as a hash
  # end

  def self.convert_to_days_hours_and_minutes(total_minutes)
    return ["0 days, 0 hours, 0 minutes", { days: 0, hours: 0, minutes: 0 }, total_minutes] if total_minutes.nil?

    # Calculate days, hours, and minutes from total minutes
    days = total_minutes / 1440          # 1440 minutes in a day
    remaining_minutes = total_minutes % 1440
    hours = remaining_minutes / 60       # Integer division gives hours
    minutes = remaining_minutes % 60     # Remainder gives minutes

    # Format the string representation
    formatted_string = "#{days} days, #{hours} hours, #{minutes} minutes"

    # Return both the formatted string, the hash, and the raw value (total_minutes)
    return [formatted_string, { days: days, hours: hours, minutes: minutes }, total_minutes]
  end


  def self.available_slots(amenity_id, target_date)
    target_date = target_date.to_date rescue nil
    return [] unless target_date.present?

    current_time = Time.now
    slots = if target_date == Date.today
      AmenitySlot.where(amenity_id: amenity_id)
      .where("start_hr > ? OR (start_hr = ? AND start_min > ?)",
             current_time.hour, current_time.hour, current_time.min)
    else
      AmenitySlot.where(amenity_id: amenity_id)
    end

    # Reject already booked slots
    available_slots = slots.reject do |slot|
      AmenityBooking.exists?(amenity_id: amenity_id, amenity_slot_id: slot.id, booking_date: target_date)
    end

    # Format response
    available_slots.map do |slot|
      slot_start_time = target_date.to_time.change(hour: slot.start_hr, min: slot.start_min)
      slot_end_time = target_date.to_time.change(hour: slot.end_hr, min: slot.end_min)
      {
        id: slot.id,
        start_hr: slot.start_hr,
        start_min: slot.start_min,
        end_hr: slot.end_hr,
        end_min: slot.end_min,
        start_time: slot_start_time.strftime('%I:%M %p'),
        end_time: slot_end_time.strftime('%I:%M %p')
      }
    end
  end


  # def self.available_slots(amenity_id, target_date)
  #   binding.pry
  #     target_date = target_date.to_date
  #     current_time = Time.now
  #     if target_date == Date.today
  #       slots = AmenitySlot.where(amenity_id: amenity_id).where("start_hr > ? OR (start_hr = ? AND start_min > ?)", current_time.hour, current_time.hour, current_time.min)
  #     else
  #       slots = AmenitySlot.where(amenity_id: amenity_id)
  #     end
  #     available_slots = slots.reject do |slot|
  #       AmenityBooking.exists?(
  #         amenity_id: amenity_id,
  #         amenity_slot_id: slot.id,
  #         booking_date: target_date
  #       )
  #     end
  #     available_slots.map do |slot|
  #       slot_start_time = target_date.to_time.change(hour: slot.start_hr, min: slot.start_min)
  #       slot_end_time = target_date.to_time.change(hour: slot.end_hr, min: slot.end_min)
  #       {
  #         id: slot.id,
  #         start_time: slot_start_time.strftime('%H:%M'), # Format as time string
  #         end_time: slot_end_time.strftime('%H:%M')      # Format as time string
  #       }
  #     end
  # end



  # Ensure payment methods are valid
  def validate_payment_methods
    return unless payment_methods

    invalid_methods = payment_methods - PAYMENT_METHODS
    if invalid_methods.any?
      errors.add(:payment_methods, "contain invalid values: #{invalid_methods.join(', ')}")
    end
  end

  # Add one or more payment methods
  def add_payment_methods(methods)
    # Filter and add only valid payment methods
    valid_methods = methods & PAYMENT_METHODS
    self.payment_methods = (payment_methods + valid_methods).uniq
    save
  end

  # Remove one or more payment methods
  def remove_payment_methods(methods)
    self.payment_methods -= methods
    save
  end

end
