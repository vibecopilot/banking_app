class RoleModule < ApplicationRecord
	has_many :site_modules
	has_many :sites, through: :site_modules
	has_many :permissions
end
