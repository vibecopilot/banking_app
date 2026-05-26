json.total_pages @amenities.total_pages
json.total_count @amenities.total_entries
json.current_page @amenities.current_page

json.amenities do
json.array! @amenities, partial: "amenities/amenity", as: :amenity
end