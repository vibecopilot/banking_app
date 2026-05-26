class AmenityNotification < ApplicationRecord
	belongs_to :user
	belongs_to :amenity_booking
end
