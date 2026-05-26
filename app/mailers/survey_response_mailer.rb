class SurveyResponseMailer < ApplicationMailer
  default from: 'noreply@myciti.life'
  
  def response_email(survey_response)
    @survey_response = survey_response
    @survey = survey_response.survey
    @message = @survey&.thank_you_message

    mail(
      to: @survey_response.respond_mail,
      subject: "Thank you for your feedback!"
    )
  end
end