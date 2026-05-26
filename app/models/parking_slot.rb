class ParkingSlot < ApplicationRecord
	belongs_to :parking_configuration, class_name: "ParkingConfiguration", foreign_key: :parking_configurations_id, optional: true
end
