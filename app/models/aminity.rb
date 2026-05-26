class Aminity < ApplicationRecord
	belongs_to :site
	has_many :aminity_setups, foreign_key: :aminity_id
	has_many :aminity_bookings, foreign_key: :aminity_id

	def setup
		aminity_setups.first
	end

	def bookings_this_week(date = Date.today)
		start_of_week = date.beginning_of_week
		end_of_week = date.end_of_week
		aminity_bookings.where(date: start_of_week..end_of_week).count
	end

	def bookings_remaining_this_week(date = Date.today)
		return nil if setup.nil? || setup.max_bookings_per_week.nil?
		setup.max_bookings_per_week - bookings_this_week(date)
	end

	def can_book_this_week?(date = Date.today)
		return true if setup.nil? || setup.max_bookings_per_week.nil?
		bookings_remaining_this_week(date) > 0
	end
end
