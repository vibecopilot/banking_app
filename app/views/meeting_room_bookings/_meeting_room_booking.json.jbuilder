json.extract! meeting_room_booking, :id, :book_type, :user_id, :booking_date, :facility_type, :payment_mode, :upi, :comment, :booking_status, :created_by_id, :created_at, :updated_at
json.user_name "#{meeting_room_booking.user&.firstname} #{meeting_room_booking.user&.lastname}"
json.created_by_name "#{(created_by_user = User.find_by(id: meeting_room_booking.created_by_id))&.firstname} #{created_by_user&.lastname}".strip
json.url meeting_room_booking_url(meeting_room_booking, format: :json)
