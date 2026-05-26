class ComplianceTrackerTag < ApplicationRecord
	belongs_to :submitted_by , class_name:'User' , foreign_key: :submitted_by_id, optional: true
	belongs_to :reviewed_by , class_name:'User' , foreign_key: :reviewed_by_id, optional: true
	belongs_to :compliance_tag_task , class_name:'ComplianceTagTask' , foreign_key: :compliance_tag_task_id
	belongs_to :compliance_tag , class_name:'ComplianceTag' , foreign_key: :compliance_tag_id
	belongs_to :compliance_tracker , class_name:'ComplianceTracker' , foreign_key: :compliance_tracker_id
end
