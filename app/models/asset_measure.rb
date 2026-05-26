class AssetMeasure < ApplicationRecord
	belongs_to :asset, class_name: "SiteAsset", foreign_key: "asset_id"
end
