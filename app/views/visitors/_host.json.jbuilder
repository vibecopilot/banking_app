json.id a.id
json.visitor_id a.visitor_id
json.user_id a.user_id
json.full_name a.user.full_name	
json.is_approved a.is_approved
json.unit_name a.user&.unit&.try(:name)
json.unit_id a.user&.unit&.id
json.approval_mode a.approval_mode
if a.user&.unit&.building_id.present?
	json.building_name Building.where(id: a.user&.unit&.building_id).pluck(:name) 
end