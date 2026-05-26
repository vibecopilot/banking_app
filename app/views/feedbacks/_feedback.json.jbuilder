json.extract! feedback, :id, :resource_type, :resource_id, :comment, :rating, :user_id, :created_at, :updated_at
json.url feedback_url(feedback, format: :json)
