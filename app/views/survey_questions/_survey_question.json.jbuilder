json.extract! survey_question, :id, :q_title,
:question_type,
:position,
:required,
:min_value,
:max_value,
:created_at,
:updated_at

# json.url survey_question_url(survey_question, format: :json)
if survey_question.options.present?
	json.options survey_question.options do |opt|
		json.extract! opt, :id, :label, :position
	end
end

if survey_question.attachments.any?
	json.attachments survey_question.attachments do |att|
		json.id att.id
		json.document_url att.document_url
	end
else
	json.attachments []
end