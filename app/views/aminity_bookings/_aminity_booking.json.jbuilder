json.extract! aminity_booking, :id, :date, :aminity_id, :comment, :cancellation_policy, :terms_and_conditions, :payment_method, :user_id, :status, :created_by_id, :created_at, :updated_at
json.aminity do
  json.extract! aminity_booking.aminity, :id, :name, :cost if aminity_booking.aminity
end
json.max_bookings_per_week aminity_booking.aminity_setup&.max_bookings_per_week
json.bookings_this_week aminity_booking.bookings_this_week
json.bookings_remaining_this_week aminity_booking.bookings_remaining_this_week
json.can_book_this_week aminity_booking.can_book_this_week?
json.url aminity_booking_url(aminity_booking, format: :json)
