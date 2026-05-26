class SurveysController < ApplicationController
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_survey, only: [:show, :edit, :update, :destroy]
  skip_before_action :set_survey, only: [:send_survey]

  def index
    @q = Survey.ransack(params[:q]).result
    @surveys = @q.where(id_of_site: @user.current_site_id).includes(:user, :survey_images,
                                                                    survey_questions: [:options], survey_responses: [:user, survey_answers: [survey_question: :options]]
                                                                    ).order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
  end

  def show
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.id_of_site = @user.current_site_id if @survey.id_of_site.blank? && @user&.current_site_id.present?
    @survey.created_by_id = @user.id if @survey.created_by_id.blank? && @user.present?
    @survey.status = "draft" if @survey.status.blank?
    ActiveRecord::Base.transaction do
      if @survey.save
        if params[:survey][:survey_images].present?
          params[:survey][:survey_images].each do |doc|
            Attachfile.create(image: doc, relation: "SurveyImage", relation_id: @survey.id, active: 1)
          end
        end
        if params[:survey][:background_image].present?
          params[:survey][:background_image].each do |doc|
            Attachfile.create(image: doc, relation: "BackgroundImage", relation_id: @survey.id, active: 1)
          end
        end
        if params[:survey][:client_logo].present?
          params[:survey][:client_logo].each do |doc|
            Attachfile.create(image: doc, relation: "ClientLogo", relation_id: @survey.id, active: 1)
          end
        end
        
        if params[:survey][:survey_questions].present?
          create_survey_questions(params[:survey][:survey_questions])
        end
        respond_to do |format|

          format.html { redirect_to @survey, notice: "Survey successfully created." }
          format.json { render :show, status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @survey.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    ActiveRecord::Base.transaction do
      if @survey.update(survey_params)
        # Update survey images
        if params[:survey][:survey_images].present?
          # records = params[:survey][:survey_images].map do |doc|
          #   {
          #     relation: "SurveyImage",relation_id: @survey.id, image:doc, active: 1
          #   }
          # end
          # Attachfile.insert_all(records)
          params[:survey][:survey_images].each do |doc|
            Attachfile.create(image: doc, relation: "SurveyImage", relation_id: @survey.id, active: 1)
          end
        end
        if params[:survey][:survey_questions].present?
          update_survey_questions(params[:survey][:survey_questions])
        end
        respond_to do |format|
          format.html { redirect_to @survey, notice: "Survey was successfully updated." }
          format.json { render :show, status: :ok }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @survey.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  def destroy
    @survey.destroy
    head :no_content
  end

  def send_survey
    emails = params[:emails].presence || []
    message = params[:message].presence || "Please take this survey!"
    survey_link = params[:survey_link].presence
    if survey_link.blank?
      return render json: { error: "Survey link is required" }, status: :unprocessable_entity
    end
    if emails.blank? || !emails.is_a?(Array) || emails.empty?
      return render json: { error: "At least one email is required" }, status: :unprocessable_entity
    end
    emails = emails.map(&:to_s).map(&:strip).reject(&:blank?).uniq
    emails.each do |email|
      SurveyMailer.survey_invitation(
        email: email,
        message: message,
        survey_link: survey_link
      ).deliver_later
    end
    render json: { message: "Survey sent successfully to #{emails.size} recipient(s)" }, status: :ok
  rescue StandardError => e
    Rails.logger.error("[SurveyMailer] Failed to send survey: #{e.message}")
    render json: { error: "Failed to send survey: #{e.message}" }, status: :internal_server_error
  end


  def create_survey_questions(questions)
    questions.each_with_index do |q, index|
      survey_q = @survey.survey_questions.create!(
        q_title: q[:q_title],
        question_type: q[:question_type],
        position: q[:position] || index + 1,
        required: q[:required] || false,
        min_value: q[:min_value],
        max_value: q[:max_value],
      )
      if q[:options].present?
        q[:options].each_with_index do |opt, opt_index|
          survey_q.options.create!(
            label: opt[:label],
            position: opt[:position] || opt_index + 1
          )
        end
      end
    end
  end

  def update_survey_questions(questions)
    questions.each do |q|
      if q[:id].present?
        survey_q = @survey.survey_questions.find_by(id: q[:id])
        next unless survey_q
        if q[:_destroy] == true || q[:_destroy] == "1"
          survey_q.destroy
          next
        end
        survey_q.update!(
          q_title: q[:q_title],
          question_type: q[:question_type],
          position: q[:position],
          required: q[:required],
          min_value: q[:min_value],
          max_value: q[:max_value]
        )
        # update_question_options(survey_q, q[:options]) if q[:options].present?
        if q[:options].present?
          q[:options].each do |l|
            if l[:id].present?
              present_opt_id = survey_q.options.find_by(id: l[:id])
              next unless present_opt_id
              if l[:_destroy] == true || l[:_destroy] == "1"
                present_opt_id.destroy
                next
              else
                present_opt_id.update!(label: l[:label], position: l[:position])
              end
            else
              survey_q.options.create!(
                label: l[:label],
                position: l[:position]
              )
            end
          end
        end
      else
        survey_q = @survey.survey_questions.create!(
          q_title: q[:q_title],
          question_type: q[:question_type],
          position: q[:position] ,
          required: q[:required] ,
          min_value: q[:min_value],
          max_value: q[:max_value],
        )
        if q[:options].present?
          q[:options].each_with_index do |opt, i|
            survey_q.options.create!(
              label: opt[:label],
              position: opt[:position] || i + 1
            )
          end
        end
      end
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:survey_title,:description,:status,:created_by_id,:start_date,:end_date,
                                   :extra, :id_of_site,
                                   survey_questions_attributes: [
                                     :q_title,
                                     :question_type,
                                     :position,
                                     :required,
                                     :min_value,
                                     :max_value,
                                     options_attributes: [:label, :position]
                                   ]
                                   )
  end
end
