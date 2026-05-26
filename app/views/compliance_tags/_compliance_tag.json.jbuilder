json.extract! compliance_tag, :id, :name, :risk, :nature, :parent_id, :resource_id, :resource_type, :company_id, :tag_type, :critical, :created_at, :updated_at
json.url compliance_tag_url(compliance_tag, format: :json)
json.compliance_tag_tasks do
  json.array! compliance_tag.compliance_tag_tasks do |compliance_tag_task|
    json.partial! "compliance_tag_tasks/compliance_tag_task", compliance_tag_task: compliance_tag_task
  end
end