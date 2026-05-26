class SurveyQuestionsController < ApplicationController
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_survey
  before_action :set_survey_question, only: [:show, :update, :destroy]

def index
  @survey_questions = SurveyQuestion.all
end
  def show
    render json: @survey_question.as_json(include: :survey_question_options)
  end

  def create
    @survey_question = @survey.survey_questions.new(survey_question_params)
    if @survey_question.save
      render json: @survey_question.as_json(include: :survey_question_options), status: :created
    else
      render json: { errors: @survey_question.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @survey_question.update(survey_question_params)
      render json: @survey_question.as_json(include: :survey_question_options)
    else
      render json: { errors: @survey_question.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @survey_question.destroy
    head :no_content
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_survey_question
    @survey_question = @survey.survey_questions.find(params[:id])
  end

  def survey_question_params
    params.require(:survey_question).permit(
      :q_title, 
      :question_type, 
      :position, 
      :required, 
      :min_value, 
      :max_value,
      options_attributes: [:id, :label, :position, :_destroy]
    )
  end
end
