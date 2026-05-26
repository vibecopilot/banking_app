class AssetParam < ApplicationRecord
	validates_presence_of :name
	belongs_to :site_asset, foreign_key: :asset_id
end
