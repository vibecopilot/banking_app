class Portal < ApplicationRecord
  has_many :user_portal_accesses, dependent: :destroy
  has_many :users, through: :user_portal_accesses

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  scope :active, -> { where(active: true) }
end
