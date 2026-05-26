json.extract! permit_extension, :id, :permit_id, :site_id, :reason, :ext_date, :ext_time, :assign_to_ids, :created_at, :updated_at
json.url permit_extension_url(permit_extension, format: :json)
user_names = User.where(id: permit_extension.assign_to_ids.split(',')).map(&:full_name)
json.assign_to_names user_names