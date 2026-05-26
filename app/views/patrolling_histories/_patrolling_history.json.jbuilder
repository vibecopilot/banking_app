json.extract! patrolling_history, :id, :user_id, :patrolling_id, :expected_time, :actual_time, :longitude, :latitude, :comment, :created_at, :updated_at

# Building, floor, and unit information from associated patrolling
json.building_name patrolling_history.patrolling&.building&.name
json.floor_name patrolling_history.patrolling&.floor&.name
json.unit_name patrolling_history.patrolling&.unit&.name

json.patrolling_time patrolling_history.expected_time.strftime("%H:%M:%S") if patrolling_history.expected_time.present?

# Use preloaded attachments to avoid N+1 queries
attachments = @attachments_by_history&.dig(patrolling_history.id) || []
json.attachments do
  json.array! attachments do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end

json.url patrolling_history_url(patrolling_history, format: :json)
