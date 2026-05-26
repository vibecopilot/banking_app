class Group < ApplicationRecord
	# has_and_belongs_to_many :users
	
	has_many :group_members, class_name: "GroupMember",foreign_key: :group_id
end

