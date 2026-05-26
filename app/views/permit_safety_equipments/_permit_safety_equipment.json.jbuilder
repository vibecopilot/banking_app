json.extract! permit_safety_equipment,
              :id,
              :safety_equipment_name,
              :permit_type_id,
              :activity_id,
              :sub_activity_id,
              :hazard_category_id,
              :permit_risk_id,
              :created_at,
              :updated_at

json.url permit_safety_equipment_url(permit_safety_equipment, format: :json)

if permit_safety_equipment.activity
  json.partial! "permit_activities/permit_activity",
                permit_activity: permit_safety_equipment.activity
end

if permit_safety_equipment.sub_activity
  json.partial! "permit_sub_activities/permit_sub_activity",
                permit_sub_activity: permit_safety_equipment.sub_activity
end

if permit_safety_equipment.hazard_category
  json.partial! "hazard_categories/hazard_category",
                hazard_category: permit_safety_equipment.hazard_category
end

if permit_safety_equipment.permit_risk
  json.partial! "permit_risks/permit_risk",
                permit_risk: permit_safety_equipment.permit_risk
end
