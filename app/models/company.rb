class Company < ApplicationRecord
  	belongs_to :organization, foreign_key: :organization_id, class_name: "Organization", optional: true
	belongs_to :created_by_user, foreign_key: :created_by, class_name: "User"
end
