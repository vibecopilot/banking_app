class GenericSubInfo < ApplicationRecord
	belongs_to :generic_info
	has_many :contact_books

	has_many :generic_sub_files, -> { where(relation: "GenericSubFile") }, foreign_key: :relation_id, class_name: "Attachfile"
	
end
