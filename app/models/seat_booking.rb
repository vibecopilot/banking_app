class SeatBooking < ApplicationRecord
	belongs_to :user
	belongs_to :building
	belongs_to :floor
end
