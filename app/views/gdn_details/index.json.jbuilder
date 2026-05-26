json.gdn_details do
  json.array! @gdn_details, partial: "gdn_details/gdn_detail", as: :gdn_detail
end

json.current_page @gdn_details.current_page
json.total_pages @gdn_details.total_pages
json.total_count @gdn_details.total_count
