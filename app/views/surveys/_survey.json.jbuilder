json.extract! survey, :id, :survey_title, :start_date, :end_date, :description, :created_by_id, :status, :extra, :id_of_site, :background_color, :header_text, :footer_text, :created_at, :updated_at
json.url survey_url(survey, format: :json)
json.created_by survey.user&.full_name

if survey.survey_images.present?
  json.survey_images survey.survey_images.active do |img|
    json.id img.id
    json.document_url img.document_url
  end
else
  json.survey_images []
end

# Branding images
json.background_image survey.background_images.active.last&.document_url
json.client_logo survey.client_logos.active.last&.document_url
json.header_image survey.header_images.active.last&.document_url
json.footer_image survey.footer_images.active.last&.document_url

if survey.survey_questions.present?
	json.survey_questions survey.survey_questions do |questions|
		json.partial! "survey_questions/survey_question", survey_question: questions
	end	
end

if survey.survey_responses.present?
	json.survey_responses survey.survey_responses do |ans|
		json.partial! "survey_responses/survey_response", survey_response: ans
	end
end