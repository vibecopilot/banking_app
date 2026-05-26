class Permission < ApplicationRecord
  belongs_to :role_accesses, optional: true
  belongs_to :role_modules, optional: true
  validates :feature, uniqueness: { scope: :role_access_id, message: "already assigned to this role" }
end
