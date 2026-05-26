class SubGroup < ApplicationRecord
	belongs_to :asset_group, foreign_key: :group_id
end
