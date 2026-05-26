json.id incident.id
json.time_and_date incident.time_and_date
json.primary_incident_category incident.primary_incident_category
json.secondary_incident_category incident.secondary_incident_category
json.incident_severity incident.incident_severity
json.incident_level incident.incident_level
json.status incident.status
# json.incident_level_id incident&.incident_level&.id

json.building_id incident.building_id
json.probability incident.probability
json.description incident.description
json.created_by_id incident.created_by_id
json.created_by_name incident.user&.full_name
json.insured_by incident.insured_by

json.primary_incident_sub_category incident.primary_incident_sub_category
json.primary_incident_sub_sub_category incident.primary_incident_sub_sub_category
json.secondary_incident_sub_category incident.secondary_incident_sub_category
json.secondary_incident_sub_sub_category incident.secondary_incident_sub_sub_category
json.property_damage incident.property_damage
json.rca incident.rca
json.primary_root_cause_category incident.primary_root_cause_category
json.corrective_action incident.corrective_action
json.preventive_action incident.preventive_action
json.first_aid_provided_employee incident.first_aid_provided_employee
json.sent_medical_treatment incident.sent_medical_treatment
json.support_required incident.support_required
json.read_facts_states incident.read_facts_states
json.read_fact_state incident.read_fact_state
json.first_aid_attendant incident.first_aid_attendant
json.treatment_facility incident.treatment_facility
json.attending_physician incident.attending_physician
json.property_damage_category incident.property_damage_category
json.damage_coverd_under_insurance incident.damage_coverd_under_insurance
json.building_name incident.building&.name

json.attachments incident.attachments.map { |a| { id: a.id, file_url: a.file.url } }
json.witnesses incident.witnesses.map { |w| { id: w.id, name: w.name, mobile: w.mobile } }
json.investigation_teams incident.investigation_teams.map { |t| { id: t.id, name: t.name, mobile: t.mobile, designation: t.designation } }
json.cost_of_incident do
  json.equipment_property_cost incident.cost_of_incident&.equipment_property_cost
  json.production_loss incident.cost_of_incident&.production_loss
  json.treatment_cost incident.cost_of_incident&.treatment_cost
  json.absenteeism_cost incident.cost_of_incident&.absenteeism_cost
  json.other_cost incident.cost_of_incident&.other_cost
  json.total_cost incident.cost_of_incident&.total_cost
end
json.incident_injuries do
  json.array! incident.incident_injuries do |incident_injury|
    json.partial! "incident_injuries/incident_injury", incident_injury: incident_injury
  end
end