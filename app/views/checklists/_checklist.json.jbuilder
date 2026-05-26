# Extract checklist details
json.extract! checklist, 
  :id, 
  :site_id, 
  :frequency, 
  :start_date, 
  :end_date, 
  :user_id, 
  :grace_period_unit, 
  :grace_period_value, 
  :created_at, 
  :updated_at, 
  :name, 
  :occurs, 
  :ctype, 
  :priority_level, 
  :grace_period, 
  :is_approved,
  :group_id,
  :sub_group_id,
  :supplier_id, 
  :lock_overdue

# Extract supervisor information
supervisor_ids = checklist.supervisior_id.present? ? JSON.parse(checklist.supervisior_id) : []
users = User.where(id: supervisor_ids)
user_full_names = users.map(&:full_name)
json.supervisors user_full_names
json.group_name checklist.group.try(:name)

# Add checklist cron
json.checklist_cron checklist.checklist_cron

# Group questions by `group_id`
questions_by_group = checklist.questions.group_by(&:group_id)

# Process and group questions
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

# Checklist URL
json.url checklist_url(checklist, format: :json)
