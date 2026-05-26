json.extract! comment, :id, :comment,:task_id, :user_id, :ctext, :active, :created_at, :updated_at,:rating,:resource_type,:resource_id
json.url comment_url(comment, format: :json)
