json.extract! address, :id, :address_title, :building_name, :street_name, :email_address, :state, :city, :address, :phone_number, :pin_code, :created_at, :updated_at
json.url address_url(address, format: :json)
