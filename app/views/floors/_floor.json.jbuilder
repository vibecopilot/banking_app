json.extract! floor, :id, :name, :building_id, :site_id
json.building_name floor.building.try(:name)
json.site_name floor.site.try(:name)
json.created_at floor.created_at
json.updated_at floor.updated_at
json.url floor_url(floor, format: :json)
