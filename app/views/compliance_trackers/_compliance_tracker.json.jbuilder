# json.extract! compliance_tracker, :id, :compliance_config_id, :status, :submitted_on, :submitted_by_id, :site_id, :due_date, :created_at, :updated_at
# json.url compliance_tracker_url(compliance_tracker, format: :json)
# json.compliance_config_name compliance_tracker.compliance_config&.name
# # json.compliance_config do
# #   json.partial! "compliance_configs/compliance_config", compliance_config: compliance_tracker.compliance_config
# # end
# cats = compliance_tracker.compliance_tracker_tags.pluck(:compliance_tag_id)
  
# json.compliance_tracker_tags do
#   json.array! compliance_tracker.compliance_tracker_tags do |compliance_tracker_tag|
#     json.partial! "compliance_tracker_tags/compliance_tracker_tag", compliance_tracker_tag: compliance_tracker_tag
#   end
# end




json.extract! compliance_tracker, :id, :compliance_config_id, :status, :submitted_on, :submitted_by_id, :site_id, :due_date, :created_at, :updated_at
json.url compliance_tracker_url(compliance_tracker, format: :json)
json.compliance_config_name compliance_tracker.compliance_config&.name

categories = ComplianceTag.where(id: compliance_tracker.compliance_tracker_tags.pluck(:compliance_tag_id)).index_by(&:id)

json.compliance_tracker_tags_by_category do
  json.array! categories.values do |category|
    json.id category.id
    json.name category.name
    json.risk category.risk
    json.nature category.nature
    json.tag_type category.tag_type
    json.critical category.critical

    json.compliance_tracker_tags do
      json.array! compliance_tracker.compliance_tracker_tags.where(compliance_tag_id: category.id) do |compliance_tracker_tag|
        json.partial! "compliance_tracker_tags/compliance_tracker_tag", compliance_tracker_tag: compliance_tracker_tag
      end
    end
  end
end
