class EventUser < ApplicationRecord
	belongs_to :event
	belongs_to :user, class_name: "User", foreign_key: 'user_id', optional: true
	belongs_to :event_guest, class_name: "EventGuest", foreign_key: 'event_guest_id', optional: true

	scope :read, -> { where(read: true) }
	scope :unread, -> { where(read: [false, nil]) }
	scope :archived, -> { where(archived: true) }
	scope :not_archived, -> { where(archived: [false, nil]) }

	def mark_as_read!
		update(read: true, read_at: Time.current) unless read?
	end

	def mark_as_unread!
		update(read: false, read_at: nil)
	end

	def mark_as_archived!
		update(archived: true, archived_at: Time.current) unless archived?
	end

	def mark_as_unarchived!
		update(archived: false, archived_at: nil)
	end
end
