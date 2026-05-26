json.id @service_booking.id
json.booking_date @service_booking.booking_date
json.status @service_booking.status
json.display_status @service_booking.display_status

json.service do
  json.id @service_booking.service_subcategory.id
  json.name @service_booking.service_subcategory.name
  json.category_name @service_booking.service_subcategory.service_category.name
  json.description @service_booking.service_subcategory.description
  json.duration_minutes @service_booking.service_subcategory.duration_minutes
end

json.time_slot do
  json.id @service_booking.service_slot.id
  json.display_time @service_booking.service_slot.display_time
  json.start_time sprintf("%02d:%02d", @service_booking.service_slot.start_hr, @service_booking.service_slot.start_min)
  json.end_time sprintf("%02d:%02d", @service_booking.service_slot.end_hr, @service_booking.service_slot.end_min)
end

json.unit do
  json.id @service_booking.unit.id
  json.name @service_booking.unit.name
  json.full_address @service_booking.unit.full_address
end

json.pricing do
  json.total_amount @service_booking.total_amount
  json.discount_amount @service_booking.discount_amount
  json.tax_amount @service_booking.tax_amount
  json.final_amount @service_booking.final_amount
end

json.payment_status @service_booking.payment_status
json.special_instructions @service_booking.special_instructions
json.can_cancel @service_booking.can_be_cancelled?
json.can_rate @service_booking.can_rate?
json.rating @service_booking.rating
json.feedback @service_booking.feedback
json.service_started_at @service_booking.service_started_at
json.service_completed_at @service_booking.service_completed_at
json.created_at @service_booking.created_at
json.transaction_id @service_booking.transaction_id
json.payment_method @service_booking.payment_method