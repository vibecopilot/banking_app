class LoiItem < ApplicationRecord
	belongs_to :item
	belongs_to :standard_unit
end
