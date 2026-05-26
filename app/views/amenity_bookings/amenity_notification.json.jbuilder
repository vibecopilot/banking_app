json.notifications do
  json.array! @amenity_notifications do |notification|
    json.id notification.id
    json.user_id notification.user_id
    json.amenity_booking_id notification.amenity_booking_id
    json.message notification.message
    json.read notification.read
    json.created_at notification.created_at
    json.updated_at notification.updated_at
  end
end