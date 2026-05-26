class ContactBook < ApplicationRecord

  	has_many :logo, -> { where(relation: "ContactBookLogo") }, :foreign_key => :relation_id, class_name: "Attachfile"		
  	has_many :attachments, -> { where(relation: "ContactBookDocument") }, :foreign_key => :relation_id, class_name: "Attachfile"		

	belongs_to :generic_info
	belongs_to :generic_sub_info, optional: true
end
