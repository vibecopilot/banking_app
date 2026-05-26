if amenity_slot.present?
  json.extract! amenity_slot, :id, :amenity_id, :start_hr, :end_hr, :start_min, :end_min, :created_at, :updated_at
  
  json.slot_str amenity_slot.slot_str
  json.twelve_hr_slot amenity_slot.twelve_hr_slot
  json.url amenity_slot_url(amenity_slot, format: :json)

else
  json.error "Amenity slot not found"
end
