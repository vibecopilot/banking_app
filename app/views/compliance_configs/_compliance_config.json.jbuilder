json.extract! compliance_config, :id, :name, :frequency, :due_in_days, :priority, :description, :assign_to_id, :reviewer_id, :start_date, :end_date, :site_id, :created_at, :updated_at
json.url compliance_config_url(compliance_config, format: :json)
json.site_name compliance_config.site&.name
json.assign_to_name compliance_config.assign_to&.full_name
json.reviewer_name compliance_config.reviewer&.full_name
json.compliance_trackers do
  json.array! compliance_config.compliance_trackers do |compliance_tracker|
    json.partial! "compliance_trackers/compliance_tracker", compliance_tracker: compliance_tracker
  end
end

@attachments = Attachfile.where(relation: 'ComplianceConfig', relation_id: compliance_config.id)
json.attachments do
  json.array! @attachments do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end
json.compliance_config_tags do
  json.array! compliance_config.compliance_config_tags do |compliance_config_tag|
    json.partial! "compliance_config_tags/compliance_config_tag", compliance_config_tag: compliance_config_tag
  end
end