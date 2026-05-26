json.extract! poll_user, :id, :poll_id, :user_id, :created_at, :updated_at
json.url poll_user_url(poll_user, format: :json)
