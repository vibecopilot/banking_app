class Card < ApplicationRecord
  belongs_to :user
  
  validates :card_id, presence: true, uniqueness: { scope: :user_id }
  validates :user_id, presence: true
  
  index_options = { unique: true }
end
