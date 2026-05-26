class VisitorCard < ApplicationRecord
  belongs_to :visitor
  
  validates :card_id, presence: true, uniqueness: { scope: :visitor_id }
  validates :visitor_id, presence: true
end
