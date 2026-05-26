class BusinessCard < ApplicationRecord
	has_one :image, -> { where(relation: "BusinessCard") }, :foreign_key => :relation_id, class_name: "Attachfile"
	belongs_to :user, foreign_key: :created_by, class_name: "User"
end
