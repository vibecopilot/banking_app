class ParkingConfiguration < ApplicationRecord
	belongs_to :building
	belongs_to :site
	belongs_to :floor
	has_many :booking_parkings, foreign_key: 'parking_id', class_name: 'BookingParking'
	has_many :parking_slots, dependent: :destroy
    accepts_nested_attributes_for :parking_slots, allow_destroy: true
end
