json.extract! ingredient, :id, :name, :sku, :category, :unit, :stock_quantity, :minimum_stock, :unit_price, :supplier_id, :site_id, :created_by_id, :created_at, :updated_at
json.supplier_name ingredient.supplier&.name
json.low_stock ingredient.low_stock?
json.out_of_stock ingredient.out_of_stock?
json.url ingredient_url(ingredient, format: :json)
