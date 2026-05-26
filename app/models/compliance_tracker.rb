class ComplianceTracker < ApplicationRecord
	belongs_to :site , class_name:'Site' , foreign_key: :site_id
	belongs_to :compliance_config , class_name:'ComplianceConfig' , foreign_key: :compliance_config_id,optional:true
	belongs_to :submitted_by , class_name:'User' , foreign_key: :submitted_by_id,optional:true
	has_many :compliance_tracker_tags

	after_create :add_tasks

	def add_tasks
		self.compliance_config.compliance_config_tags.each do |compliance_config_tag|
		  	compliance_config_tag.compliance_tag.compliance_tag_tasks.each do |task|
		  	  ComplianceTrackerTag.create(compliance_tracker_id: self.id, compliance_tag_id: task.compliance_tag_id, compliance_tag_task_id: task.id)
		  	end
		  end
	end
end
