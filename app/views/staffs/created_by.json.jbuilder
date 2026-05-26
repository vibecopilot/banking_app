  json.current_page @staffs.current_page
  json.total_pages @staffs.total_pages
  json.total_count @staffs.total_entries


json.staffs do
json.array! @staffs, partial: "staffs/created_by", as: :staff
end