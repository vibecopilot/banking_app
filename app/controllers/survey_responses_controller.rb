class SurveyResponsesController < ApplicationController
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_survey
  before_action :set_survey_response, only: [:show]

  def index
    @responses = @survey.survey_responses.includes(survey_answers: :survey_question)
    render json: @responses.as_json(include: { survey_answers: { include: :survey_question } })
  end

  def show
    render json: @survey_response.as_json(include: { survey_answers: { include: :survey_question } })
  end

  def new
  end

  def create
    @survey_response = @survey.survey_responses.new(survey_response_params)
    if @survey_response.save
      render json: @survey_response.as_json(include: :survey_answers), status: :created
    else
      render json: { errors: @survey_response.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_survey_response
    @survey_response = @survey.survey_responses.find(params[:id])
  end

  def survey_response_params
    params.require(:survey_response).permit(
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
