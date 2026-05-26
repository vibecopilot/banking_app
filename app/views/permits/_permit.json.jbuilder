json.extract! permit, :id, :name, :contact_number, :site_id, :unit_id, :permit_for, :building_id, :floor_id, :room_id, :client_specific, :entity, :copy_to_string, :permit_type, :vendor_id, :issue_date_and_time, :expiry_date_and_time, :comment, :permit_status, :extention_status, :created_by_id, :created_at, :updated_at
json.url permit_url(permit, format: :json)
json.created_by permit.created_by&.full_name
json.building_name permit.building&.name
json.floor_name permit.floor&.name
json.unit_name permit.unit&.name
# json.permit_type_name permit.permit_type&.name
json.vendor_name permit.vendor&.vendor_name
json.site_name permit.site&.name
json.total_permits Permit.where(site_id:@user.current_site_id).count
json.total_drafts Permit.where(permit_status:"draft",site_id:@user.current_site_id).count
json.total_open Permit.where(permit_status:"open",site_id:@user.current_site_id).count
json.total_approved Permit.where(permit_status:"approved",site_id:@user.current_site_id).count
json.total_rejected Permit.where(permit_status:"rejected",site_id:@user.current_site_id).count
json.total_extended Permit.where(permit_status:"extended",site_id:@user.current_site_id).count
json.total_closed Permit.where(permit_status:"closed",site_id:@user.current_site_id).count
json.permit_activities do
  json.array! permit.permit_activities do |permit_activity|
    json.extract! permit_activity, :id, :permit_id, :activity, :sub_activity, :category_of_hazards, :risks, :created_at, :updated_at
    json.url permit_activity_url(permit_activity, format: :json)
  end
end