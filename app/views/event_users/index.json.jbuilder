
json.total_entries @event_users.total_entries
json.total_pages @event_users.total_pages
json.current_page @event_users.current_page
json.event_users do
json.array! @event_users, partial: "event_users/event_user", as: :event_user
end