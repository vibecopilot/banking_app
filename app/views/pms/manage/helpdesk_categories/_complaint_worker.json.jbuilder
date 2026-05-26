json.id worker.id
json.society_id worker.society_id
json.category_id worker.category_id
json.assign_to worker.assign_to
json.created_at worker.created_at
json.updated_at worker.updated_at
json.of_phase worker.of_phase
json.of_atype worker.of_atype
json.site_id worker.site_id
json.issue_related_to worker.issue_related_to
json.esc_type worker.esc_type
json.cloned_by_id worker.cloned_by_id
json.cloned_at worker.cloned_at

if worker.category.present?
  json.category do
    json.id worker.category.id
    json.name worker.category.name
  end
end

json.sub_category_id worker.sub_category_id

if worker.sub_category_id.present?
  sub = HelpdeskSubCategory.find_by(id: worker.sub_category_id)
  json.sub_category_name sub&.name
end

json.escalations worker.escalations do |escalation|
  json.id escalation.id
  json.cw_id escalation.cw_id
  json.name escalation.name
  json.p1 escalation.p1
  json.p2 escalation.p2
  json.p3 escalation.p3
  json.p4 escalation.p4
  json.p5 escalation.p5
  json.escalate_to_users escalation.escalate_to_users
  json.escalate_to_users_names User.where(id: escalation.escalate_to_users).pluck(:firstname, :lastname).map { |f, l| "#{f} #{l}" }
  json.society_id escalation.society_id
end

if worker.assignee_id.present?
  json.assignee do
    assignee = User.find_by(id: worker.assignee_id)
    if assignee
      json.id assignee.id
      json.email assignee.email
      json.active assignee.active
      json.full_name assignee.full_name if assignee.respond_to?(:full_name)
    end
  end
end