json.array! @service_subcategories do |subcategory|
  json.id subcategory.id
  json.name subcategory.name
  json.description subcategory.description
  json.category_name subcategory.service_category.try(:name)
  json.category_id subcategory.service_category.id
  json.service_category_id subcategory.service_category_id
  json.duration_minutes subcategory.duration_minutes
  json.advance_booking_hours subcategory.advance_booking_hours
  json.cancellation_hours subcategory.cancellation_hours
  json.slots_count subcategory.service_slots.active.count
  json.created_at subcategory.created_at
  json.active subcategory.active
end
