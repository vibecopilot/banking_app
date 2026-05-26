json.extract! event_guest, :id, :event_id, :user_id, :name, :rsvp, :company_name, :email, :mobile, :business, :rules, :charges, :industry, :created_at, :updated_at
json.url event_guest_url(event_guest, format: :json)
