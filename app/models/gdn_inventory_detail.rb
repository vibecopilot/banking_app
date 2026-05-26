class GdnInventoryDetail < ApplicationRecord
	belongs_to :gdn_detail, foreign_key: 'gdn_id'
	belongs_to :site_asset, class_name: "SiteAsset", foreign_key: 'asset_id', optional: true
	belongs_to :soft_service, class_name: "SoftService", foreign_key: 'service_id', optional: true
	belongs_to :item, optional: true
end
