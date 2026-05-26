json.extract! seat_booking, :id, :book_type, :user_id, :booking_date, :building_id, :floor_id, :booking_status, :created_by_id, :created_at, :updated_at
json.user_name "#{seat_booking.user&.firstname} #{seat_booking.user&.lastname}"
json.building_name seat_booking.building&.name
json.floor_name seat_booking.floor&.name
json.created_by_name "#{(created_by_user = User.find_by(id: seat_booking.created_by_id))&.firstname} #{created_by_user&.lastname}".strip
json.url seat_booking_url(seat_booking, format: :json)
