class GoodsItem < ApplicationRecord
  belongs_to :goods_in_out
  
  validates :item_name, :quantity, :unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end
