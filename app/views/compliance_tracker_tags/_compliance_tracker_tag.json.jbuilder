json.extract! compliance_tracker_tag, :id, :compliance_tracker_id,:status, :submitted_on, :submitted_by_id, :compliance_tag_id, :observation, :recommendtion, :comment, :compliance_tag_task_id,:reviewed_by_id,:objective,:reviewed_on, :created_at, :updated_at
json.url compliance_tracker_tag_url(compliance_tracker_tag, format: :json)
json.reviewed_by_name compliance_tracker_tag.reviewed_by&.full_name
json.submitted_by_name compliance_tracker_tag.submitted_by&.full_name

@attachments = Attachfile.where(relation: 'ComplianceTrackerTag', relation_id: compliance_tracker_tag.id)
json.attachments do
  json.array! @attachments do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end

json.task do
  json.partial! "compliance_tag_tasks/compliance_tag_task", compliance_tag_task: compliance_tracker_tag.compliance_tag_task
end