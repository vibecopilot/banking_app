json.extract! aminity, :id, :name, :site_id, :cost, :created_at, :updated_at
json.site_name aminity.site&.name
json.max_bookings_per_week aminity.setup&.max_bookings_per_week
json.bookings_this_week aminity.bookings_this_week
json.bookings_remaining_this_week aminity.bookings_remaining_this_week
json.can_book_this_week aminity.can_book_this_week?
json.url aminity_url(aminity, format: :json)
