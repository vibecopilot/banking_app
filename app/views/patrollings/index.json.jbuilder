json.current_page @patrollings.current_page
json.total_pages @patrollings.total_pages
json.total_count @patrollings.total_entries
json.per_page @patrollings.limit_value

json.patrollings do
  json.array! @patrollings, partial: "patrollings/patrolling", as: :patrolling
end
