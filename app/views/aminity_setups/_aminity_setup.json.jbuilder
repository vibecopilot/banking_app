json.extract! aminity_setup, :id, :aminity_id, :name, :site_id, :unit_id, :start_time, :end_time, :slot_frequency, :max_bookings_per_week, :created_at, :updated_at
json.bookings_this_week aminity_setup.bookings_this_week
json.bookings_remaining_this_week aminity_setup.bookings_remaining_this_week
json.can_book_this_week aminity_setup.can_book_this_week?
json.url aminity_setup_url(aminity_setup, format: :json)
