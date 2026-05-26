class Ticket < ApplicationRecord
  has_many :ticket_items
  has_many :items, through: :ticket_items
end
