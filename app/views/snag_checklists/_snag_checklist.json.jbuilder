json.extract! snag_checklist, :id, :name, :snag_audit_category_id, :snag_audit_sub_category_id, :active, :site_id, :company_id, :check_type, :user_id, :resource_id, :resource_type, :created_at, :updated_at
json.url snag_checklist_url(snag_checklist, format: :json)

json.category_name snag_checklist&.fitout_category.try(:name)
json.site_name snag_checklist&.site&.try(:name)

json.total_questions snag_checklist.snag_questions.count
json.questions do 
 json.array! snag_checklist.snag_questions, partial: "snag_questions/snag_question", as: :snag_question	
end


