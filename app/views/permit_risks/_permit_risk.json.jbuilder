json.extract! permit_risk, :id, :permit_type_id, :activity_id, :sub_activity_id, :hazard_category_id, :risk_description, :created_at, :updated_at, :risk_name
json.url permit_risk_url(permit_risk, format: :json)
json.permit_type_name permit_risk.permit_activity_setup&.permit_type&.name
json.activity_name permit_risk.permit_activity_setup&.name
json.sub_activity_name permit_risk.permit_sub_activity&.name
json.hazard_category_name permit_risk.hazard_category&.name