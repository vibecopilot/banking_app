class VisitorCategory < ApplicationRecord
	has_many :visitor_sub_categories, dependent: :destroy	
	has_many :visitors
	has_one :icon , -> { where(relation: "VisitorCategory") }, foreign_key: :relation_id , class_name: "Attachfile"	, dependent: :destroy
	accepts_nested_attributes_for :icon, allow_destroy: true
	
	validates :name, uniqueness: { scope: :site_id }
end
