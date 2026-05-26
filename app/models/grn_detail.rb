class GrnDetail < ApplicationRecord
  has_many :inventory_details, foreign_key: 'grn_id', dependent: :destroy
  belongs_to :vendor, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id , optional: true

  validates :grn_unique_id, uniqueness: true, presence: true
  
end