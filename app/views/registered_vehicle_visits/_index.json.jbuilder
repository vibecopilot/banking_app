json.extract! vehicle_logs, :id, :registered_vehicle_id,  :check_out, :site_id, :created_by_id, :created_at, :updated_at, :no_of_people


json.registered_user vehicle_logs&.user&.full_name
# json.check_in vehicle_logs&.check_in.strftime("%d/%m/%Y %H:%M:%S")
json.check_in vehicle_logs&.check_in

json.registered_vehicle do
  json.extract! vehicle_logs&.registered_vehicle,
    :slot_number,
    :vehicle_category,
    :vehicle_type,
    :vehicle_number,
    :unit_id

   json.unit_name  vehicle_logs&.registered_vehicle&.unit.try(:name)
end
