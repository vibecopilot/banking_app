json.extract! status_restaurant, :id, :status, :display_name, :fixed_state, :order, :color, :created_at, :updated_at
json.url status_restaurant_url(status_restaurant, format: :json)
json.status status_restaurant.generic_info&.name
