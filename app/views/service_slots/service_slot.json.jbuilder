json.array! @service_slots do |slot|
  json.id slot.id
  json.start_time slot.start_time.strftime('%I:%M %p')
  json.end_time slot.end_time.strftime('%I:%M %p')
  json.display_time slot.display_time
  json.max_bookings slot.max_bookings
  json.active slot.active

  json.subcategory do
    json.partial! 'service_subcategories/service_sub_cat', service_subcategory: slot.service_subcategory
  end

  json.subcategory_id slot.service_subcategory.id
end
