json.extract! visitor_visit, :id, :visitor_id, :check_in, :check_out, :created_at, :updated_at
json.url visitor_visitor_visit_url(visitor_visit.visitor, visitor_visit, format: :json)