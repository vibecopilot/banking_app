json.extract! deleted_user, :id, :email, :mobile, :first_name, :last_name, :created_at, :updated_at
json.url deleted_user_url(deleted_user, format: :json)
