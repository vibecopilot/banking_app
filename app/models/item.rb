class Item < ApplicationRecord
  has_many :ticket_items
  has_many :inventory_details
  has_many :tickets, through: :ticket_items
  belongs_to :asset_group, foreign_key: :group_id, optional: true
  belongs_to :sub_group, foreign_key: :sub_group_id, optional: true

  def name_with_rate
	"#{self.name} - #{self.rate}"
  end
end
