json.extract! organization, :id, :name, :created_by_id, :created_at, :updated_at, :company_name, :entity, :site, :country, :region, :state, :city, :zonr, :white_label, :sub_domain, :billing_type, :billing_for, :billing_term, :rate_per_bill, :billing_cycle, :start_time, :end_time
json.url organization_url(organization, format: :json)
