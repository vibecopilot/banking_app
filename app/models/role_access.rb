class RoleAccess < ApplicationRecord
  belongs_to :site
  has_many :permissions, dependent: :destroy
  accepts_nested_attributes_for :permissions
  validates :title, uniqueness: { scope: :site_id, message: "already exists for this site" }
end