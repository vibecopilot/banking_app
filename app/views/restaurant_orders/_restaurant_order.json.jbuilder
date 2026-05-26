json.extract! restaurant_order, :id, :restaurant_id, :ondate, :ontime, :user_id,
              :payment_status, :total_amount, :status, :table_number,
              :booking_id, :order_type, :customer_name, :customer_phone,
              :customer_address, :service_charge, :tax_amount, :discount,
              :paid_amount, :payment_mode, :billed_at, :completed_at,
              :confirm_token, :confirmed_at,
              :restaurant_table_id, :table_name,
              :delivery_charges, :convenience_fee,
              :created_at, :updated_at
json.restaurant_name restaurant_order.food_and_beverage&.restaurant_name
json.qr_image_url restaurant_order.qr_image_url.present? ? "#{request.base_url}#{restaurant_order.qr_image_url}" : nil
json.created_by restaurant_order.created_by&.full_name
json.restaurant_order_items restaurant_order.restaurant_order_items do |item|
  json.extract! item, :id, :restaurant_menu_id, :quantity, :amount, :rate
  json.restaurant_menu item.restaurant_menu
end
json.url restaurant_order_url(restaurant_order, format: :json)
