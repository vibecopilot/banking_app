class RoomAvailability < ApplicationRecord
  belongs_to :room

  validates :date, presence: true, uniqueness: { scope: :room_id }
  validates :available, inclusion: { in: [true, false] }

  scope :available_dates, -> { where(available: true) }
  scope :blocked_dates, -> { where(available: false) }
  scope :for_date_range, ->(start_date, end_date) {
    where(date: start_date..end_date)
  }

  def self.block_dates(room, start_date, end_date, reason = nil)
    (start_date..end_date).each do |date|
      find_or_create_by(room: room, date: date) do |availability|
        availability.available = false
        availability.reason = reason
      end
    end
  end

  def self.unblock_dates(room, start_date, end_date)
    where(room: room, date: start_date..end_date).destroy_all
  end

  def self.set_availability(room, date, available, reason = nil)
    availability = find_or_initialize_by(room: room, date: date)
    availability.available = available
    availability.reason = reason if reason
    availability.save!
  end

  def blocked?
    !available
  end

  def display_reason
    reason.presence || (available? ? 'Available' : 'Blocked')
  end
end
