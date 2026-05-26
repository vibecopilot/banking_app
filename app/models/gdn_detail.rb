class GdnDetail < ApplicationRecord
	has_many :gdn_inventory_details, class_name: "GdnInventoryDetail",foreign_key: :gdn_id
end
