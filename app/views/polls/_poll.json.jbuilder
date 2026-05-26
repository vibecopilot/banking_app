json.extract! poll, :id, :title, :description, :start_date,:send_mail, :end_date, :visibility, :target_groups, :created_by_id, :created_at, :updated_at,
:group_id, :group_name ,:share_with, :start_time,:end_time, :shared
json.poll_options poll.poll_options do |option|
  json.extract! option, :id, :content
  json.votes option.poll_votes.count
  json.voted_to PollVote.where(poll_id: poll.id, poll_user_id: @user.id, poll_option_id: option.id).present?
end
json.users do
  json.array!(poll.poll_users) do |poll_user|
    json.extract! poll_user, :id, :user_id, :poll_id
    json.name poll_user&.user&.full_name
  end
end

json.active poll.active?
json.has_voted PollVote.where(poll_id: poll.id, poll_user_id: @user.id).present?

json.url poll_url(poll, format: :json)
