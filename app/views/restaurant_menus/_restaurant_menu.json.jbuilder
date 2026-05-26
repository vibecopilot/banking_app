json.extract! restaurant_menu, :id, :restaurant_id, :name, :sku, :price, :active, :category_id, :sub_category_id, :description, :prep_time, :spice_level, :is_favorite, :created_at, :updated_at, :master_price
json.category_name restaurant_menu.category.try(:name)
json.sub_category_name restaurant_menu.sub_category.try(:name)
json.image_url restaurant_menu.menu_image&.document_url
json.url restaurant_menu_url(restaurant_menu, format: :json)
