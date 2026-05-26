json.extract! complaint_status, :id, :society_id, :name, :color_code, :fixed_state, :active, :position, :of_phase, :of_atype
json.created_at complaint_status.created_at
json.updated_at complaint_status.updated_at
json.url complaint_status_url(complaint_status, format: :json)
