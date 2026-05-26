json.extract! user_refferal, :id, :from_user_id, :refferal_type, :to_user_id, :date_time, :name, :mobile, :email, :business, :amount, :created_at, :updated_at
json.url user_refferal_url(user_refferal, format: :json)

json.from_user do
	user = user_refferal.from_user
	json.id user.id
  json.email user.email
  json.firstname user.firstname
  json.lastname user.lastname
end

json.attachments do
  json.array! user_refferal.attachments do |attachment|
    json.id attachment.id
    json.url attachment.document_url
    json.whole_path attachment.whole_path
  end
end

json.to_user do
	user = user_refferal.to_user
	json.id user.id
  json.email user.email
  json.firstname user.firstname
  json.lastname user.lastname
end

