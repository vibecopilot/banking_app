json.total_pages @incidents.total_pages
json.total_count @incidents.total_count
json.current_page @incidents.current_page\

json.incidents do
  json.array! @incidents, partial: "incidents/incident", as: :incident
end
