class StatusRestaurant < ApplicationRecord
	serialize :fixed_state, Array
	belongs_to :generic_info, foreign_key: "status",class_name: "GenericInfo"

end
