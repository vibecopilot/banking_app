json.extract! checklist_user, :id, :resource_id, :checklist_id, :resource_type, :user_id, :created_at, :updated_at
json.url checklist_user_url(checklist_user, format: :json)
