json.total_pages @amenity_bookings.total_pages
json.current_page @amenity_bookings.current_page
json.total_count @amenity_bookings.total_entries
#json.per_page @visitors.per_page

json.amenity_bookings do
json.array! @amenity_bookings, partial: "amenity_bookings/amenity_booking", as: :amenity_booking
end
