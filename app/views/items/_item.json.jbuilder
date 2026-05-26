json.extract! item, :id, :site_id, :name, :description, :rate, :available_quantity, :created_by_id, :created_at, :updated_at, :max_stock, :min_stock
json.group_id item.asset_group&.id
json.group_name item.asset_group&.name
json.sub_group_id item.sub_group&.id
json.sub_group_name item.sub_group&.name

json.url item_url(item, format: :json)
