json.total_count @seat_bookings.total_entries
json.total_pages @seat_bookings.total_pages
json.current_page @seat_bookings.current_page

json.seat_bookings do
  json.array! @seat_bookings, partial: "seat_bookings/seat_booking", as: :seat_booking
end