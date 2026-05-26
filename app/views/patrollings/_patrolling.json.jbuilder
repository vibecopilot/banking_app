json.extract! patrolling, :id, :patrolling_name, :site_id, :building_id, :floor_id, :unit_id, :start_date, :end_date, :start_time, :end_time, :time_intervals, :specific_times, :longitude, :latitude, :created_at, :updated_at
json.building_name patrolling.building&.name
json.floor_name patrolling.floor&.name
json.unit_name patrolling.unit&.name

# Optimized patrolling logs loading with preloaded attachments
recent_logs = patrolling.patrolling_histories.includes(:user).limit(100).order(:expected_time)
if recent_logs.any?
  # Preload attachments for all logs in one query
  log_attachments = Attachfile.where(
    relation: 'PatrollingHistory', 
    relation_id: recent_logs.map(&:id)
  ).group_by(&:relation_id)
  
  json.patrolling_logs recent_logs do |log|
    json.extract! log, :id, :user_id, :patrolling_id, :expected_time, :actual_time, :longitude, :latitude, :comment, :created_at, :updated_at
    json.patrolling_time log.expected_time.strftime("%H:%M:%S") if log.expected_time.present?
    
    # Use preloaded attachments
    attachments = log_attachments[log.id] || []
    json.attachments do
      json.array! attachments do |image|
        json.extract! image, :id, :relation, :relation_id
        json.image_url image.document_url
      end
    end
  end
else
  json.patrolling_logs []
end

json.qr_code_image_url patrolling.qr_code_image.try(:document_url)
json.url patrolling_url(patrolling, format: :json)
