json.id @survey.id
json.survey_title @survey.survey_title
json.description @survey.description
json.status @survey.status
json.background_color @survey.background_color
json.header_text @survey.header_text
json.footer_text @survey.footer_text

# Branding images
json.background_image @survey.background_images.active.last&.document_url
json.client_logo @survey.client_logos.active.last&.document_url
json.header_image @survey.header_images.active.last&.document_url
json.footer_image @survey.footer_images.active.last&.document_url

if @survey.survey_questions.present?
  json.survey_questions @survey.survey_questions do |q|
    json.partial! "survey_questions/survey_question", survey_question: q
  end
else
  json.survey_questions []
end
