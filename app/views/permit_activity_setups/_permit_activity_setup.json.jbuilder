json.extract! permit_activity_setup, :id, :permit_type_id, :name, :site_id, :created_at, :updated_at, :parent_id
json.parent permit_activity_setup.permit_type&.name
json.url permit_activity_setup_url(permit_activity_setup, format: :json)
