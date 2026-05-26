json.extract! audit_task, :id, :group, :sub_group, :task, :input_type, :mandatory, :reading, :help_text, :weightage, :rating, :audit_id, :created_by_id, :created_at, :updated_at
json.url audit_task_url(audit_task, format: :json)


json.audit_name audit_task.audit.try(:activity_name)