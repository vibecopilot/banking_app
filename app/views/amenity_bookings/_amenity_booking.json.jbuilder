json.extract! amenity_booking, :id, :amenity_id,:amenity_slot_id, :is_book_hotel, :user_id, :booking_date, :site_id, :created_at, :updated_at,:amount,:member_adult,:member_child,:guest_adult,:guest_child,:no_of_members,:no_of_guests, :tenant_adult, :tenant_child, :no_of_tenants, :status, :is_prime_booking, :payment_mode
json.url amenity_booking_url(amenity_booking, format: :json)

json.checkin_at amenity_booking.checkin_at&.strftime("%Y-%m-%d %H:%M")
json.checkout_at amenity_booking.checkout_at&.strftime("%Y-%m-%d %H:%M")

json.book_by_user amenity_booking&.user&.full_name

json.max_bookings_per_week amenity_booking.amenity_setup&.max_bookings_per_week
json.bookings_this_week amenity_booking&.amenity_setup&.bookings_this_week
json.bookings_remaining_this_week amenity_booking&.amenity_setup&.bookings_remaining_this_week
json.can_book_this_week amenity_booking&.amenity_setup&.can_book_this_week?

json.payment do 
json.partial! "payments/payment", payment: amenity_booking.payment
end
json.amenity do 
	json.partial! "amenities/amenity", amenity: amenity_booking.amenity
end
json.slot do 
	json.partial! "amenity_slots/amenity_slot", amenity_slot: amenity_booking.amenity_slot
end