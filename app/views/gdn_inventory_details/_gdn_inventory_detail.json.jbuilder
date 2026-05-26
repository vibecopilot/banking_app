json.extract! gdn_inventory_detail, :id, :inventory, :current_stock, :quantity, :comments, :gdn_id, :created_at, :updated_at
json.url gdn_inventory_detail_url(gdn_inventory_detail, format: :json)
