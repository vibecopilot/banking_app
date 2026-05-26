json.total_pages @permits.total_pages
json.current_page @permits.current_page
json.total_count @permits.total_count

json.permits do
  json.array! @permits, partial: "permits/permit", as: :permit
end