class TicketItem < ApplicationRecord
	belongs_to :complaint, foreign_key: :ticket_id
	belongs_to :item
	validates_uniqueness_of :item_id, scope: :ticket_id
end
