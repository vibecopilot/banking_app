class UserRefferal < ApplicationRecord
	belongs_to :from_user, class_name: "User"
	belongs_to :to_user, class_name: "User"
  	has_many :attachments, -> { where(relation: "UserRefferal") }, :foreign_key => :relation_id, class_name: "Attachfile"
end
