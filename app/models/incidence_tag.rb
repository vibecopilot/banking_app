class IncidenceTag < ApplicationRecord
	belongs_to :parent, class_name: "IncidenceTag", foreign_key: :parent_id, optional:true
	has_many :children, class_name: 'IncidenceTag', foreign_key: 'parent_id'
  	validates_uniqueness_of :name, :scope => [:active, :tag_type, :parent_id, :resource_id, :resource_type]
 	validates :name, presence: true, uniqueness: { scope: [:resource_id, :resource_type] }
end
