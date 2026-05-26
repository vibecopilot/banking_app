json.current_page @hsns.current_page
json.total_pages @hsns.total_pages
json.total_count @hsns.total_count

json.hsns do
json.array! @hsns, partial: "hsns/hsn", as: :hsn
end