class ComplianceTag < ApplicationRecord
	belongs_to :parent, class_name: "ComplianceTag", foreign_key: :parent_id, optional:true
	has_many :children, class_name: 'ComplianceTag', foreign_key: 'parent_id'
	has_many :compliance_tag_tasks
	belongs_to :company , class_name:'Company' , foreign_key: :company_id
end
