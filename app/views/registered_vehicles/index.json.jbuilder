json.current_page @registered_vehicles.current_page
json.total_count @registered_vehicles.total_entries
json.total_pages @registered_vehicles.total_pages

json.registered_vehicles do
json.array! @registered_vehicles, partial: "registered_vehicles/registered_vehicle", as: :registered_vehicle
end