class FlightRequest < ApplicationRecord
	  has_many :additional_passengers, 
           class_name: 'AdditionalPassenger', 
           foreign_key: 'flight_request_id', 
           dependent: :destroy
      accepts_nested_attributes_for :additional_passengers, allow_destroy: true
end
