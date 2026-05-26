json.extract! project, :id, :user_id, :name, :active,:pincode,:state, :address_line_one, :address_line_two, :company_name, :entity, :site, :country, :region, :zone, :white_label, :sub_domain, :billing_type, :rate_per_bill, :billing_for, :billing_term, :billing_cycle, :start_date, :end_date, :created_at, :updated_at
json.url project_url(project, format: :json)
