json.success true
json.total_count @bookings&.count || 0

json.bookings @bookings do |b|

  json.id b.id
  json.title b.amenity&.fac_name

  json.type b.amenity&.is_hotel ? "guest_room" : "amenity"

  # Date logic
  if b.amenity&.is_hotel

    json.start b.checkin_at&.strftime("%Y-%m-%d")
    json.end b.checkout_at&.strftime("%Y-%m-%d")

  else

    json.start b.booking_date&.strftime("%Y-%m-%d")
    json.end b.booking_date&.strftime("%Y-%m-%d")

  end

  json.colors @colors[b.id.to_s.last.to_i]

  json.booked_by b.user&.full_name

  json.url amenity_booking_url(b, format: :json)

  json.details do
    json.partial! "amenity_bookings/amenity_booking",
                  amenity_booking: b
  end

end