json.total_count @booking_parkings.total_entries
json.current_page @booking_parkings.current_page
json.total_pages @booking_parkings.total_pages

json.booking_parkings do
json.array! @booking_parkings, partial: "booking_parkings/booking_parking", as: :booking_parking
end