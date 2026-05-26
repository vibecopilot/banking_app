json.extract! snag_answer, :id, :question_id, :quest_option_id, :resource_type, :resource_id, :ans_descr, :comments, :user_id, :company_id, :checklist_id, :answer_type, :answer_mode, :created_at, :updated_at
json.url snag_answer_url(snag_answer, format: :json)

json.user_name snag_answer.users.try(:full_name)
json.question_descr snag_answer.snag_question.try(:descr)