json.extract! permit_sub_activity, :id, :name, :permit_type_id, :permit_activity_setup_id, :created_at, :updated_at
json.permit_type permit_sub_activity.permit_type&.name
json.permit_activity_setup permit_sub_activity.permit_activity_setup&.name

json.url permit_sub_activity_url(permit_sub_activity, format: :json)
