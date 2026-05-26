json.extract! mom_task, :id, :mom_detail_id, :description, :responsible_person_id, :target_date, :responsible_person_email, :responsible_person_type, :responsible_person_name, :company_tag_id, :created_at, :updated_at
json.url mom_task_url(mom_task, format: :json)
