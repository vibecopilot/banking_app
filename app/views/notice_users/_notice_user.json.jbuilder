json.extract! notice_user, :id, :notice_id, :user_id, :created_at, :updated_at
@user = User.find_by(id: notice_user.user_id)
json.user_name @user.try(:full_name)
json.url notice_user_url(notice_user, format: :json)

