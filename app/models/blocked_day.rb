class BlockedDay < ApplicationRecord
	    belongs_to :f_and_b, class_name: "FoodAndBeverage", foreign_key: "restaurant_id"


end
