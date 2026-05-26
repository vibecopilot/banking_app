json.extract! hazard_category, :id, :name, :description, :sub_activity_id, :activity_id, :site_id, :created_at, :updated_at
json.permit_type_name hazard_category.permit_activity_setup&.permit_type&.name
json.permit_type_id hazard_category.permit_activity_setup&.permit_type&.id
json.activity_name hazard_category.permit_activity_setup&.name
json.sub_activity_name hazard_category.permit_sub_activity&.name
json.url hazard_category_url(hazard_category, format: :json)
