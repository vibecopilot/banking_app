json.extract! building, :id, :name, :site_id, :floor_no
json.site_name building.site&.name
# json.floor_no building.floors.count
json.created_at building.created_at
json.updated_at building.updated_at
json.url building_url(building, format: :json)
