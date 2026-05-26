class ComplianceConfigTag < ApplicationRecord
	belongs_to :compliance_config, class_name:'ComplianceConfig',foreign_key: :compliance_config_id,optional: true
	belongs_to :compliance_tag, class_name:'ComplianceTag',foreign_key: :compliance_tag_id,optional: true
	has_many :compliance_tag_tasks
end
