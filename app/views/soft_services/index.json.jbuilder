json.total_count @total_count
json.current_page @current_page
json.total_pages @total_pages

json.soft_services do
  json.array! @soft_services,
              partial: "soft_services/soft_service",
              as: :soft_service
end
