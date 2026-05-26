json.extract! gdn_detail, :id, :gdn_date, :description, :status, :created_by_id, :created_at, :updated_at
json.url gdn_detail_url(gdn_detail, format: :json)

json.gdn_inventory_details do
	json.array! gdn_detail.gdn_inventory_details do |gdn_inventory_detail|
		json.extract! gdn_inventory_detail, :id, :inventory, :current_stock, :quantity, :comments, :gdn_id, :created_at, :updated_at, :purpose_id, :handover_to_id, :consuming_in_id, :asset_id, :service_id
		
		# Only add URL if record is persisted
		if gdn_inventory_detail.persisted?
			json.url gdn_inventory_detail_url(gdn_inventory_detail, format: :json)
		end
		
		# Safe navigation for associations
		json.soft_service gdn_inventory_detail.soft_service&.name
		json.site_asset gdn_inventory_detail.site_asset&.name
	end
end