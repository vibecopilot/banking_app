json.extract! purchase_order, :id, :order_number, :supplier_id, :order_date, :status, :total_amount, :notes, :site_id, :created_by_id, :created_at, :updated_at
json.supplier_name purchase_order.supplier&.name
json.created_by_name purchase_order.created_by&.full_name
json.purchase_order_items purchase_order.purchase_order_items do |item|
  json.extract! item, :id, :ingredient_id, :quantity, :unit_price, :total_price
  json.ingredient_name item.ingredient&.name
end
json.url purchase_order_url(purchase_order, format: :json)
