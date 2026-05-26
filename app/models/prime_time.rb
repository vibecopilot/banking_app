class PrimeTime < ApplicationRecord
  belongs_to :amenity_booking_rules, optional: true
end
