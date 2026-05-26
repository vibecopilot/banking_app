class InventoryDetail < ApplicationRecord
  belongs_to :grn_detail, foreign_key: 'grn_id'
  belongs_to :item , class_name: "Inventory", foreign_key: 'item_id'
end