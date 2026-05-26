object false
child(@helpdesk_categories => :helpdesk_categories) do
  extends "pms/manage/helpdesk_categories/show"
end
# child(@issue_types => :issue_types) do
#   attributes :id, :society_id, :name, :active
# end
child(@statuses => :statuses) do
  attributes :id, :society_id, :name, :active, :color_code
end
