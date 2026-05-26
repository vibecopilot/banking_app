json.total_count @attendances_json.total_entries
json.current_page @attendances_json.current_page
json.total_pages @attendances_json.total_pages

json.attendances do
json.array! @attendances_json, partial: "attendances/attendance", as: :attendance
end