json.extract! restaurant_order_item, :id, :order_id, :restaurant_menu_id, :quantity, :amount, :rate, :created_at, :updated_at
json.url restaurant_order_item_url(restaurant_order_item, format: :json)
