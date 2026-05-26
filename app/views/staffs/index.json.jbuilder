json.total_count @staffs.total_entries
json.total_pages @staffs.total_pages
json.current_page @staffs.current_page


json.staffs do
json.array! @staffs, partial: "staffs/staff", as: :staff
end