json.extract! compliance_config_tag, :id, :compliance_tag_id, :compliance_config_id, :created_at, :updated_at
json.url compliance_config_tag_url(compliance_config_tag, format: :json)
json.compliance_config_name compliance_config_tag.compliance_config&.name
json.compliance_tag_name compliance_config_tag.compliance_tag&.name
if compliance_config_tag.compliance_tag.present?
	json.compliance_tag do 
		json.partial! "compliance_tags/compliance_tag", compliance_tag: compliance_config_tag.compliance_tag
	end
end