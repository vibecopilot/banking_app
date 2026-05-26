json.extract! poll_option, :id, :content, :poll_id, :created_at, :updated_at
json.url poll_option_url(poll_option, format: :json)
