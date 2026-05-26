json.extract! @reg_vehicle,
  :id,
  :slot_number,
  :vehicle_category,
  :vehicle_type,
  :sticker_number,
  :registration_number,
  :insurance_number,
  :insurance_valid_till,
  :category,
  :vehicle_number,
  :unit_id,
  :user_id, :created_by_id,
  :status, :valid_till ,:site_id, :created_at, :updated_at , :approved, :vehicle_in_out

json.created_by_name do
  json.firstname @reg_vehicle.created_by&.firstname
  json.lastname  @reg_vehicle.created_by&.lastname
end

json.user_name do
  json.firstname @reg_vehicle.user&.firstname
  json.lastname  @reg_vehicle.user&.lastname
end

json.slot_name @reg_vehicle.parking_configuration&.name
json.qr_code_image_url @reg_vehicle.qr_code_image.try(:document_url)
json.vehicle_logs @reg_vehicle.registered_vehicle_visits do |visit|
  json.extract! visit,
     :id, :check_in,  :check_out, :site_id, :created_by_id, :created_at, :updated_at
end
