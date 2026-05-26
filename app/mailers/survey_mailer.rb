# frozen_string_literal: true

class SurveyMailer < ApplicationMailer
  default from: "noreply@myciti.life"

  def survey_invitation(email:, message:, survey_link:, survey_id: nil)
    @survey = Survey.find_by(id: survey_id) if survey_id.present?
    @message = message.presence || @survey&.invitation_message
    @survey_link = survey_link

    mail(
      to: email,
      subject: "Feedback Form – please take this survey"
    )
  end
end
