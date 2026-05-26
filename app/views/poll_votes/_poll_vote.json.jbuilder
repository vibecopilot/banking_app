json.extract! poll_vote, :id, :poll_user_id, :poll_id, :poll_option_id, :created_at, :updated_at
json.url poll_vote_url(poll_vote, format: :json)
