class UserSite < ApplicationRecord
	belongs_to :user
	belongs_to :site

	belongs_to :unit, optional: true
end
