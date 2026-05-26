json.extract! extension, :id, :permit_id, :ext_date, :ext_time, :created_by_id, :created_at, :updated_at
json.url extension_url(extension, format: :json)
json.created_by_name extension&.user&.full_name
