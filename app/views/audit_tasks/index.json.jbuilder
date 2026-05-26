json.total_count @audit_tasks.total_entries
json.current_page @audit_tasks.current_page
json.total_pages @audit_tasks.total_pages

json.audit_tasks do
 json.array! @audit_tasks, partial: "audit_tasks/audit_task", as: :audit_task
end