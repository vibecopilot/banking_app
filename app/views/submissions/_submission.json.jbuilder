json.extract! submission, :id, :asset_id, :checklist_id, :activity_id, :question_id, :value, :user_id, :created_at, :updated_at, :soft_service_id, :patrolling_id, :asset_param_id
json.asset_name submission.site_asset&.name
json.checklist_name Checklist.unscoped.find_by(id: submission.checklist_id)&.name
json.question_name submission.question&.name
json.soft_service_name submission.soft_service&.name
json.asset_param_name submission.asset_param&.name
json.user_name submission.user&.full_name

json.comment submission.comment
json.consumption @consumption_map.present? ? @consumption_map[submission.id] : nil

json.question_attachments do
  @attachments = Attachfile.where("relation LIKE 'Question-#{submission.question_id}' and relation_id = ?", submission.id)
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

@attachments = Attachfile.where("relation = 'SubmissionDocuments' and relation_id = ?", submission.id)
json.submission_attachments do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end 
end
