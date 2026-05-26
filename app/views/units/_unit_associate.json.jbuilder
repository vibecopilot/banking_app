json.site do
  if unit.site
    json.extract! unit.site, :id, :name
  else
    json.nil!
  end
end

json.unit_name do
  json.unit_id unit.id
  json.unit_name unit.try(:name)
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
