json.extract! approval, :id, :site_id, :user_id, :level_id, :start_date, :end_date, :status, :end_date, :resource_id, :resource_type, :comments, :approved_by_id, :approver_comments, :created_at, :updated_at, :current_level, :total_amount
json.url approval_url(approval, format: :json)

json.user_name approval.user&.full_name
json.approver_name approval&.approved_by&.full_name

json.levels approval.approval_levels.order(:order) do |l|
  json.id l.id
  json.approver l.name.presence || l.user&.full_name || "User ##{l.user_id}"
  json.threshold l.threshold&.to_f
  json.decision l.decision.presence || "pending"
  json.comment l.comment
  json.acted_at l.acted_at
end