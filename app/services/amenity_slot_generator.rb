class AmenitySlotGenerator
  VALID_SLOT_DURATIONS = ['15 min', '30 min', '1 hr', '1.5 hr', '2 hr', '3 hr', '6 hr', '12 hr', '24 hr'].freeze

  def initialize(amenity)
    @amenity = amenity
    @amenity_id = amenity.id
  end

  def generate_slots
    validate_configuration!

    existing_slot_ids = AmenitySlot.where(amenity_id: @amenity_id).pluck(:id)
    if existing_slot_ids.any?
      booked_slots = AmenityBooking.where(amenity_slot_id: existing_slot_ids).where.not(status: ["cancelled", "rejected"])
      if booked_slots.exists?
        raise "Cannot regenerate slots — active bookings exist. Please cancel/delete bookings first."
      end
    end

    AmenitySlot.where(amenity_id: @amenity_id).delete_all
    slots = []
    current_time = parse_time(@amenity.slot_start_time)
    end_time = parse_time(@amenity.slot_end_time)
    break_start = @amenity.break_time_start.present? ? parse_time(@amenity.break_time_start) : nil
    break_end = @amenity.break_time_end.present? ? parse_time(@amenity.break_time_end) : nil
    slot_duration_minutes = duration_to_minutes(@amenity.slot_by)
    wrap_time_minutes = @amenity.wrap_time || 0

    while current_time < end_time
      slot_end = current_time + slot_duration_minutes.minutes

      # Skip if slot falls within break time
      if break_start.present? && break_end.present?
        if slot_overlaps_break?(current_time, slot_end, break_start, break_end)
          current_time = break_end + wrap_time_minutes.minutes
          next
        end
      end

      # Don't create slot if it extends beyond end time
      break if slot_end > end_time

      slot = create_slot(current_time, slot_end)
      slots << slot if slot.persisted?

      current_time = slot_end + wrap_time_minutes.minutes
    end

    { success: true, slots_created: slots.count, slots: slots }
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def validate_configuration!
    raise "Slot start time is required" if @amenity.slot_start_time.blank?
    raise "Slot end time is required" if @amenity.slot_end_time.blank?
    raise "Slot duration (slot_by) is required" if @amenity.slot_by.blank?
    raise "Invalid slot duration. Must be one of: #{VALID_SLOT_DURATIONS.join(', ')}" unless VALID_SLOT_DURATIONS.include?(@amenity.slot_by)
    raise "Concurrent slot must be greater than 0" if @amenity.concurrent_slot.to_i <= 0
  end

  def parse_time(time_value)
    return time_value if time_value.is_a?(Time)
    return time_value.to_time if time_value.is_a?(DateTime)
    
    # If it's a string, parse it
    if time_value.is_a?(String)
      Time.parse(time_value)
    else
      # If it's a date/datetime, convert to time
      time_value.to_time
    end
  end

  def duration_to_minutes(duration_str)
    case duration_str
    when '15 min'
      15
    when '30 min'
      30
    when '1 hr'
      60
    when '1.5 hr'
      90
    when '2 hr'
      120
    when '3 hr'
      180
    when '6 hr'
      360
    when '12 hr'
      720
    when '24 hr'
      1440
    else
      raise "Invalid duration: #{duration_str}"
    end
  end

  def slot_overlaps_break?(slot_start, slot_end, break_start, break_end)
    # Check if slot overlaps with break time
    slot_start < break_end && slot_end > break_start
  end

  def create_slot(start_time, end_time)
    AmenitySlot.create(
      amenity_id: @amenity_id,
      start_hr: start_time.hour,
      start_min: start_time.min,
      end_hr: end_time.hour,
      end_min: end_time.min
    )
  end
end
