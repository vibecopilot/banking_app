json.extract! site, :id, :name, :region, :active, :longitude, :latitude, :account_id, :city, :address, :site_code, :project_id, :selected_product, :country, :activation_date, :site_owner, :phone_no, :email_address
json.feature site.features
json.company_id site.company&.id
json.company_name site.company&.name
json.created_at site.created_at
json.updated_at site.updated_at
json.url site_url(site, format: :json)

# Adding the helpdesk_operations nested within the site object
json.helpdesk_operations site.helpdesk_operations do |operation|
	json.id operation.id
    json.op_of operation.op_of
    json.op_of_id operation.op_of_id
    json.dayofweek operation.dayofweek
    json.of_phase operation.of_phase
    json.is_open operation.is_open
    json.start_hour operation.start_hour
    json.start_min operation.start_min
    json.end_hour operation.end_hour
    json.end_min operation.end_min
end