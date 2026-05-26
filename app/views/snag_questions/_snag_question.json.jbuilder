json.extract! snag_question, :id, :qtype, :descr, :checklist_id, :user_id, :img_mandatory, :quest_mandatory, :active, :company_id, :qnumber, :created_at, :updated_at
json.url snag_question_url(snag_question, format: :json)

json.options do
json.array! snag_question.snag_quest_options , partial: "snag_quest_options/snag_quest_option", as: :snag_quest_option
end