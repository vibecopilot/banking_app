json.total_pages @visitor_visits.total_pages
json.current_page @visitor_visits.current_page
json.total_count @visitor_visits.total_count

json.visit_logs @visitor_visits do |visit|
  json.partial! 'visitor_visits/visitor_visit', visitor_visit: visit
end