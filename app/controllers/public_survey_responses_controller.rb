# Public survey response submission: no auth required. Anyone can submit.
class PublicSurveyResponsesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :api_user, raise: false
  skip_before_action :set_user, raise: false

  def create
    survey = Survey.find_by(id: params[:survey_id], status: "active")
    unless survey
      render json: { error: "Survey not found or not available" }, status: :not_found
      return
    end

    response = survey.survey_responses.new(survey_response_params)
    if response.save
      render json: response.as_json(include: :survey_answers), status: :created
    else
      render json: { errors: response.errors }, status: :unprocessable_entity
    end
  end

  private
  def survey_response_params
    params.require(:survey_response).permit(
      :user_id,
      :user_id,
      :company_name,
      :floor_unit,
      :feedback_date,
      :feedback_given_by,
      :contact_details,
      survey_answers_attributes: [:survey_question_id, :text_value, :numeric_value, selected_option_ids: []]
    )
  end
end
