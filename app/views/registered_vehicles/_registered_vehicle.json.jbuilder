json.extract! registered_vehicle, :id, :slot_number, :vehicle_category, :vehicle_type, :sticker_number, :registration_number, :insurance_number, :insurance_valid_till, :category, :vehicle_number, :unit_id, :user_id, :created_by_id, 
:status, :valid_till ,:site_id, :created_at, :updated_at , :approved, :vehicle_in_out
json.created_by_name  User.find_by(id: registered_vehicle.created_by_id)&.slice(:firstname, :lastname)
json.user_name  User.find_by(id: registered_vehicle.user_id)&.slice(:firstname, :lastname)
json.slot_name ParkingConfiguration.find_by(id: registered_vehicle.slot_number)&.name

@attachments = Attachfile.where("relation = 'RegisteredVehicleDocument' and relation_id = ?", registered_vehicle.id)
json.registered_vehicle_attachments do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end


json.qr_code_image_url registered_vehicle.qr_code_image.try(:document_url)
json.url registered_vehicle_url(registered_vehicle, format: :json)

