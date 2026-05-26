class UserCategory < ApplicationRecord
	belongs_to :user, optional: true
end
