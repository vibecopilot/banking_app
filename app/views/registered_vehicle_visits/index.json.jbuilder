json.current_page @registered_vehicle_visits.current_page
json.total_count @registered_vehicle_visits.total_entries
json.total_pages @registered_vehicle_visits.total_pages

json.vehicle_logs do
json.array!  @registered_vehicle_visits, partial: "index", as: :vehicle_logs
end