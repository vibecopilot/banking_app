json.grn_details do
  json.array! @grn_details, partial: "grn_details/grn_detail", as: :grn_detail
end

json.current_page @grn_details.current_page
json.total_pages @grn_details.total_pages
json.total_count @grn_details.total_count
