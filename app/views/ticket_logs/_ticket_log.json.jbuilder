json.extract! ticket_log, :id, :ticket_id, :created_by_id, :status, :log_type, :remarks, :created_at, :updated_at
json.url ticket_log_url(ticket_log, format: :json)
