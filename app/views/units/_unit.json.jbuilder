json.extract! unit, :id, :name, :site_id, :unit_configuration_id
json.site_name unit.site&.name
json.building_id unit.building_id
json.building_name unit.building&.name
json.floor_id unit.floor_id
json.floor_name unit.floor&.name
json.unit_configuration_name unit.unit_configuration_name
json.unit_type unit.unit_type
json.full_address unit.full_address
json.with_floor_building unit.with_floor_building

json.unit_configuration do
  if unit.unit_configuration
    json.extract! unit.unit_configuration, :id, :name, :description, :bedrooms, :bathrooms, :halls, :kitchens, :carpet_area, :built_up_area, :active
    json.display_name unit.unit_configuration.display_name
    json.area_info unit.unit_configuration.area_info
  else
    json.nil!
  end
end

json.site do
  if unit.site
    json.extract! unit.site, :id, :name
  else
    json.nil!
  end
end

json.building do
  if unit.building
    json.extract! unit.building, :id, :name
  else
    json.nil!
  end
end

json.floor do
  if unit.floor
    json.extract! unit.floor, :id, :name
  else
    json.nil!
  end
end

json.created_at unit.created_at
json.updated_at unit.updated_at
json.url unit_url(unit, format: :json)
