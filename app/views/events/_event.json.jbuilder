json.extract! event, :id, :site_id, :event_name, :enabled, :venue, :discription, :start_date_time, :end_date_time, :created_at, :status ,:updated_at, :group_id, :email_enabled, :rsvp_enabled, :important,:shared
json.url event_url(event, format: :json)
json.created_by event&.user&.full_name
json.created_by_id event&.created_by
# json.discription ActionView::Base.full_sanitizer.sanitize(event.discription)
json.description ActionController::Base.helpers.sanitize(
  event.discription,
  tags: %w[p br strong em a ul ol li h1 h2 h3 h4 h5 h6],
  attributes: %w[href target rel]
)
json.group_name event&.group&.group_name
json.site_name event.site.name
@feedbacks = Comment.where(resource_type: 'Event', resource_id: event.id)

json.feedbacks do
  json.array!(@feedbacks) do |feedback|
    json.extract! feedback, :id, :resource_id, :resource_type
    json.feedback feedback&.comment
  end
end

# json.guests do
#   json.array! event.event_guest, partial: "event_guests/event_guest", as: :event_guest
# end

json.qr_code event&.qr_code&.document_url

json.users do
  json.array!(event.event_users) do |event_user|
    json.extract! event_user, :id, :user_id, :event_id
    json.name event_user&.user&.full_name || event_user.event_guest&.name
    json.event_guest_id event_user&.event_guest_id  
    json.rsvp event_user&.rsvp
    json.check_in event_user&.checked_in_at
  end
end

json.event_images do
  json.array!(event.attachfiles) do |attach|
    json.extract! attach, :id, :relation, :relation_id
    json.document_url attach.document_url
  end
end
