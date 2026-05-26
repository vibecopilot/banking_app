class AminityBooking < ApplicationRecord
	belongs_to :aminity, foreign_key: :aminity_id
	
	def aminity_setup
		aminity&.setup
	end

	def bookings_this_week
		aminity&.bookings_this_week || 0
	end

	def bookings_remaining_this_week
		aminity&.bookings_remaining_this_week
	end

	def can_book_this_week?
		aminity&.can_book_this_week? || true
	end
end
