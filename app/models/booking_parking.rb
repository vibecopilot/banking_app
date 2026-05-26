class BookingParking < ApplicationRecord
	belongs_to :parking_configuration, foreign_key: 'parking_id', class_name: 'ParkingConfiguration', primary_key: 'id' 
	belongs_to :user
	belongs_to :created_by , class_name: "User", foreign_key: :created_by_id
	belongs_to :parking_slot, foreign_key: 'slot_id', class_name: 'ParkingSlot',optional:true 
	# belongs_to :parking_configuration, foreign_key: 'parking_id', class_name: 'ParkingConfiguration'


	ransacker :search do |parent|
   Arel.sql(
    "CONCAT_WS(' ',
        booking_parkings.id,
        booking_parkings.status,
        users.firstname,
        users.lastname,
        parking_configurations.name,
        parking_configurations.vehicle_type,
        buildings.name,
        floors.name
      )"
    )
  end
end
