json.extract! audit, :id, :audit_for, :activity_name, :description, :allow_observations, :checklist_type, :asset_name, :service_name, :vendor_name, :training_name, :assign_to, :scan_type, :plan_duration, :priority, :email_trigger_rule, :supervisors, :category, :look_overdue_task, :frequency, :start_from, :end_at, :select_supplier, :created_by_id, :created_at, :updated_at
json.url audit_url(audit, format: :json)

json.audit_tasks do
  json.array! audit.audit_tasks do |audit_task|
    json.extract! audit_task, :id, :group, :sub_group, :task, :input_type, :mandatory, :reading, :help_text, :weightage, :rating, :audit_id, :created_by_id, :created_at, :updated_at
    json.url audit_task_url(audit_task, format: :json)
  end
end