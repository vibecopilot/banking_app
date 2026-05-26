json.counts @counts

json.activities @activities do |activity|
  json.extract! activity, :id, :asset_id, :checklist_id, :start_time, :end_time, :status, :assigned_to, :created_at, :updated_at

  # Checklist
  json.checklist_name activity.checklist&.name
  json.checklist_frequency activity.checklist&.frequency
  json.checklist_group activity.checklist&.group&.name

  # Site Asset / Soft Service
  json.asset_name activity.site_asset&.name
  json.soft_service_id activity.soft_service&.id
  json.soft_service_name activity.soft_service&.name

  # Assigned Users
  assigned_names = activity.checklist&.users&.map(&:full_name)&.uniq&.join(', ')
  json.assigned_to_name assigned_names.presence || ""

  # JSON URL
  json.url activity_url(activity, format: :json)
end
