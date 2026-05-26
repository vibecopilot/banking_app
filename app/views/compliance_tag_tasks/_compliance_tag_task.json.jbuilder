json.extract! compliance_tag_task, :id, :name, :weightage,:mandatory, :compliance_tag_id, :created_at, :updated_at
json.url compliance_tag_task_url(compliance_tag_task, format: :json)
json.compliance_tag_name compliance_tag_task.compliance_tag&.name
attachment = Attachfile.find_by(relation: 'ComplianceTagTask', relation_id: compliance_tag_task.id)
json.attachment_url attachment&.document_url