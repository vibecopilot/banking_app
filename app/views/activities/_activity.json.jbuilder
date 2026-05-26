# json.extract! activity, :id, :asset_id, :checklist_id, :start_time, :end_time, :status, :assigned_to, :created_at, :updated_at
# json.asset_name activity.site_asset&.name
# json.soft_service_id activity.soft_service&.id
# json.soft_service_name activity.soft_service&.name
# json.checklist_name Checklist.unscoped.find_by(id: activity.checklist_id)&.name
# json.checklist_frequency Checklist.unscoped.find_by(id: activity.checklist_id)&.frequency
# @users = User.where(id: activity.checklist.checklist_users.pluck(:user_id))
# json.assigned_to_name @users.map(&:full_name).join(',')
# soft_service = activity.soft_service
# json.location "#{soft_service&.site&.name}/ #{soft_service&.building&.name}/ #{soft_service&.floor&.name}/ #{soft_service.try(:units).try(:map, &:name).try(:join, ', ')}".presence || "Unknown location"
# json.url activity_url(activity, format: :json)






#Optimization Code 
# app/views/activities/_activity.json.jbuilder

json.extract! activity, :id, :asset_id, :checklist_id, :start_time, :end_time, :status, :assigned_to, :created_at, :updated_at

# Access checklist attributes directly from the eager-loaded activity.checklist
json.checklist_name activity.checklist&.name
json.checklist_frequency activity.checklist&.frequency
# json.assigned_to activity&.user&.full_name
json.assigned_to activity&.assigned_to

json.asset_name activity&.site_asset&.name
json.soft_service_id activity.soft_service&.id
json.soft_service_name activity.soft_service&.name

# Access assigned users directly from the eager-loaded checklist.users
# This assumes Checklist has `has_many :users, through: :checklist_users` defined
json.assigned_to_name activity.checklist&.users&.map(&:full_name)&.uniq&.join(',')

# Location handling for both soft_service and site_asset
if activity.soft_service.present?
  soft_service = activity.soft_service
  # SoftService can have multiple units (comma-separated unit_ids)
  unit_names = soft_service.units&.name.join(', ') rescue ""
  json.location "#{soft_service.site&.name}/ #{soft_service.building&.name}/ #{soft_service.floor&.name}/ #{unit_names}".strip
else 
  site_asset = activity.site_asset
  # SiteAsset has a single unit
  unit_name = site_asset&.unit&.name || ""
  json.location "#{site_asset&.site&.name}/ #{site_asset&.building&.name}/ #{site_asset&.floor&.name}/ #{unit_name}".strip
end

questions_by_group = activity&.checklist&.questions.group_by(&:group_id)

json.groups do
  json.array! questions_by_group do |group_id, questions|
    json.group_id group_id
  json.questions do
    json.array! questions do |question|
      # Assuming a partial is being rendered for questions
      json.partial! "questions/question", question: question
    end
  end
  end
end
json.url activity_url(activity, format: :json)