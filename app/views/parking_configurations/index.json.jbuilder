# json.total_count @parking_configurations.total_entries
# json.current_page @parking_configurations.current_page
# json.total_pages @parking_configurations.total_pages

# json.parking_configurations do
json.array! @parking_configurations, partial: "parking_configurations/parking_configuration", as: :parking_configuration
# end