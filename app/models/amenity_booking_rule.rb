class AmenityBookingRule < ApplicationRecord
	
	has_many :prime_times, dependent: :destroy
	accepts_nested_attributes_for :prime_times
end
