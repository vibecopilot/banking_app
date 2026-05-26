json.extract! inventory, :id, :name, :inventory_type, :category, :criticality, :asset_group_id, :asset_sub_group_id, :asset_id, :code, :serial_number, :quantity, :min_stock_level, :min_order_level, :cgst_rate, :sgst_rate, :igst_rate, :active, :hsn_id, :expiry_date, :unit, :cost, :created_at, :updated_at, :site_id
json.url inventory_url(inventory, format: :json)

json.group_id inventory.asset_group&.id
json.group_name inventory.asset_group&.try(:name)
json.sub_group_id inventory.sub_group&.id
json.sub_group_name inventory.sub_group&.try(:name)

json.assets do
  json.site_name inventory&.site_asset&.site&.name
  json.building_name inventory&.site_asset&.building&.name
  json.floor_name inventory.site_asset&.floor&.name
  # json.area_name inventory.site_asset.area&.name
  json.group_name inventory.site_asset&.asset_group&.name
  json.sub_group_name inventory.site_asset&.sub_group&.name
end