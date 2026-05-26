json.extract! event_user, :id, :event_id, :user_id, :rsvp, :created_at, :updated_at
@user = User.find_by(id: event_user.user_id)
json.user_name @user.try(:full_name)
json.url event_user_url(event_user, format: :json)
