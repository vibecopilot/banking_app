json.extract! soft_service, :id, :site_id, :building_id, :floor_id, :name, :user_id, :generic_info_id, :generic_sub_info_id, :longitude, :latitude, :created_at, :updated_at
json.url soft_service_url(soft_service, format: :json)
json.site_name soft_service.site&.name
json.building_name soft_service.building&.name
json.floor_name soft_service.floor&.name
json.user_name "#{soft_service.user&.firstname} #{soft_service.user&.lastname}"
json.qr_code_image_url soft_service.qr_code_image.try(:document_url)

json.units soft_service.related_units do |unit|
  json.id unit&.id
  json.name unit.try(:name)
end




# Only include activities if requested (for performance optimization)
if @include_activities
  # Use preloaded activities and limit to first 250 for performance
  activities_limited = soft_service.activities.sort_by(&:start_time).reverse.first(250)

  json.activities do
    json.array! activities_limited do |activity|
      json.id activity.id
      json.asset_id activity.asset_id
      json.checklist_id activity.checklist_id
      json.start_time activity.start_time
      json.end_time activity.end_time
      json.status activity.status
      json.assigned_to activity.assigned_to
      json.soft_service_id activity.soft_service_id
      json.patrolling_id activity.patrolling_id
      json.group_id activity.group_id
    end
  end
else
  json.activities []
end

@soft_service_attach = soft_service.attachfiles
json.soft_service_attach do
  json.array!(@soft_service_attach) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end


# Use preloaded attachments from controller
attachments = @attachments_by_service&.dig(soft_service.id) || []
json.attachments do
  json.array!(attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

json.cron_setting do
  json.recurrence_type soft_service.cron_setting&.recurrence_type
  json.year_interval soft_service.cron_setting&.year_interval
  json.month soft_service.cron_setting&.month
  json.date soft_service.cron_setting&.date
  json.hour soft_service.cron_setting&.hour
  json.minute soft_service.cron_setting&.minute
end
# json.sub_group_id soft_service.sub_group&.id
# json.group_name site_asset.asset_group&.name
# json.sub_group_name site_asset.sub_group&.name

