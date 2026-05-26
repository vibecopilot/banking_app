json.current_page @service_bookings.current_page
json.total_pages @service_bookings.total_pages
json.total_count @service_bookings.total_count

json.service_bookings do
  json.array! @service_bookings, partial: 'service_bookings/service_booking', as: :service_booking
end
