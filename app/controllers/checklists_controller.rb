class ChecklistsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user, except: [:download]
  before_action :api_user, except: [:download]
  before_action :set_user, except: [:download]
  before_action :set_checklist, only: %i[ show edit update destroy delete_question ]

  # GET /checklists or /checklists.json
  def index
    @q = Checklist.ransack(params[:q])
    @checklists = @q.result.where(site_id: @user.current_site_id).where.not(ctype: "master").order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
    if params[:format] == "json"
      @checklists = @q.result.where(site_id: @user.current_site_id).where.not(ctype: "master").order(created_at: :DESC).page(params[:page]).per(params[:per_page] || 100)
    end
  end

  def export_checklist
    @checklists = Checklist.where(site_id: @user.current_site_id).where.not(ctype: "master")
    #Apply date filter in q
    if params[:q].present?
      start_date = params[:q][:start_date]
      end_date   = params[:q][:end_date]
      if start_date.present? && end_date.present?
        @checklists = @checklists.where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
      end
    end
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="checklist.xlsx"'
      }
    end
  end
  # GET /checklists/1 or /checklists/1.json
  def show
    if params[:format] == "xlsx"
      asset = SiteAsset.find_by(id: params[:asset_id])
      render xlsx: "showexcel", filename: @checklist.name + ' - ' + asset.name + '.xlsx'
    end
  end

  def get_master_checklist
    Rails.logger.info "Inside get_master_checklist action"
    @checklists = Checklist.where(company_id: @user.company_id, ctype: "master").order(created_at: :desc)
    respond_to do |format|
      format.json { render 'index' }
    end
  end

  # GET /checklists/new
  def new
    @checklist = Checklist.new
  end

  def import
    @file = params[:file]
    @uploadds = Checklist.import(@file, @user)
    respond_to do |format|
      format.html {
        redirect_to request.referrer + "#" , notice: "Successfully imported Measurement"
      }
      format.json { render json: @uploadds }
    end
  end

  def ppm
    @checklists = Checklist.unscoped.where(site_id: @user.current_site_id, ctype: "ppm")
    @ppm = true
    render :index
  end

  # GET /checklists/1/edit
  def edit
  end
  #get subgroup
  def get_subgroups
    if params[:q].present? && params[:q][:group_id_eq].present?
      @subgroups = SubGroup.where(group_id: params[:q][:group_id_eq])
    else
      @subgroups = SubGroup.where(company_id: current_user.company.try(:id)) || []
    end
    respond_to do |format|
      format.json do
        render json: { subgroups: @subgroups.as_json }
      end
    end
  end
  def download
    file_path = Rails.root.join("app", "assets", "files", "Checklist Template.xlsx")

    if File.exist?(file_path)
      send_file file_path, type: "application/xlsx", disposition: "attachment"
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end




  def create
    @checklist = Checklist.new(checklist_params)
    @checklist.frequency = params[:frequency]

    respond_to do |format|
      if @checklist.save
        # Handle cron expression if present
        if params[:checklist][:cron_expression].present?
          ChecklistCron.create(checklist_id: @checklist.id, expression: params[:checklist][:cron_expression])
        end

        ticket_created = false # Flag to track ticket creation for "Checklist" level
        if params[:groups].present?
          params[:groups].each do |group|
            group_id = group[:group]

            group[:questions].each_with_index do |qs, index|
              # Create the question
              question = Question.new(
                checklist_id: @checklist.id,
                group_id: group_id,
                name: qs[:name],
                help_text: qs[:help_text],
                qtype: qs[:type],
                option1: qs[:options][0],
                option2: qs[:options][1],
                option3: qs[:options][2],
                option4: qs[:options][3],
                value_type1: qs[:value_types][0],
                value_type2: qs[:value_types][1],
                value_type3: qs[:value_types][2],
                value_type4: qs[:value_types][3],
                question_mandatory: qs[:question_mandatory],
                image_mandatory: qs[:image_mandatory] == "1",
                help_text_enbled: qs[:help_text_enbled],
                rating: qs[:rating],
                weightage: qs[:weightage],
                reading: qs[:reading]
              )

              if question.save
                # Handle image upload if present
                if qs["image_for_question#{index + 1}"].present?
                  Attachfile.create(
                    image: qs["image_for_question #{index + 1}"],
                    relation: "QuestionHint",
                    relation_id: question.id,
                    active: 1
                  )
                end
              end

              # Handle ticket creation
              if @checklist.ticket_enabled
                if @checklist.ticket_level_type == "Checklist" && !ticket_created
                  # Checklist Level: Create one ticket if any question has type "N"
                  if qs[:value_types].include?("N")
                    begin
                      Complaint.transaction do
                        Complaint.create!(
                          assigned_to: params[:assigned_to],
                          issue_status: "Pending",
                          priority: "High",
                          heading: @checklist.try(:name),
                          id_user: @user.id,
                          category_type_id: @checklist.category_id,
                          site_id: @user.current_site_id

                        )
                      end
                    rescue ActiveRecord::RecordInvalid => e
                      Rails.logger.error "Complaint creation failed: #{e.message}"
                    end

                    ticket_created = true # Mark ticket as created
                  end
                elsif @checklist.ticket_level_type == "Question"
                  # Question Level: Create a ticket for each question with type "N"
                  if [question.value_type1, question.value_type2, question.value_type3, question.value_type4].include?("N")
                    begin
                      Complaint.transaction do
                        Complaint.create!(
                          assigned_to: params[:assigned_to],
                          issue_status: "Pending",
                          priority: "High",
                          heading: question.try(:name),
                          id_user: @user.id,
                          category_type_id: @checklist.category_id,
                          site_id: @user.current_site_id
                        )
                      end
                    rescue ActiveRecord::RecordInvalid => e
                      Rails.logger.error "Complaint creation failed: #{e.message}"
                    end

                  end
                end
              end
            end
          end
        end

        # Send checklist creation email
        begin
          @checklist.send_creation_email
        rescue => e
          Rails.logger.error "Failed to send checklist creation email: #{e.message}"
        end

        format.html { redirect_to @checklist, notice: 'Checklist was successfully created.' }
        format.json { render :show, status: :created, location: @checklist }
      else
        format.html { render :new }
        format.json { render json: @checklist.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /checklists/1 or /checklists/1.json
  def update
    respond_to do |format|
      @checklist.frequency = params[:frequency]
      if @checklist.update(checklist_params)
        if params[:checklist][:cron_expression].present?
          acc = ChecklistCron.find_by(checklist_id: @checklist.id)
          if acc.present?
            acc.update(expression: params[:checklist][:cron_expression])
          else
            ChecklistCron.create(checklist_id: @checklist.id,expression: params[:checklist][:cron_expression])
          end
        end

        update_questions
        if @checklist.saved_change_to_start_date? || @checklist.saved_change_to_end_date? || params[:frequency].present? || params[:checklist][:cron_expression].present?
          @checklist.reset_future_activities!
        end

        # Send checklist update email
        begin
          @checklist.send_update_email
        rescue => e
          Rails.logger.error "Failed to send checklist update email: #{e.message}"
        end
        # params[:question].each do |qs|
        #   qns = Question.find_or_create_by(checklist_id: @checklist.id, name: qs[:name])
        #   qns.update(qtype: qs[:type], option1: qs[:option1], option2: qs[:option2], option3: qs[:option3], option4: qs[:option4], question_mandatory: qs[:question_mandatory] == "1", image_mandatory: qs[:image_mandatory] == "1") if qns.present?
        # end
        # params[:question].each do |qs|
        #   if qs[:id].present?
        #     # Update existing question
        #     question = @checklist.questions.find(qs[:id])
        #     question.update(name: qs[:name], qtype: qs[:type], option1: qs[:option1], option2: qs[:option2], option3: qs[:option3], option4: qs[:option4], question_mandatory: qs[:question_mandatory] == "1", image_mandatory: qs[:image_mandatory] == "1")
        #   else
        #     # Create new question
        #     @checklist.questions.create(name: qs[:name], qtype: qs[:type], option1: qs[:option1], option2: qs[:option2], option3: qs[:option3], option4: qs[:option4], question_mandatory: qs[:question_mandatory] == "1", image_mandatory: qs[:image_mandatory] == "1")
        #   end
        # end

        format.html { redirect_to @checklist, notice: "Checklist was successfully updated." }
        format.json { render :show, status: :ok, location: @checklist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklists/1 or /checklists/1.json
  def destroy
    @checklist.destroy
    respond_to do |format|
      format.html { redirect_to checklists_url, notice: "Checklist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # DELETE /checklists/1/delete_questionx
  def delete_question
    question = @checklist.questions.find(params[:question_id])
    question.destroy
    respond_to do |format|
      format.html { redirect_to edit_checklist_path(@checklist), notice: "Question was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def update_questions
    return unless params[:groups].present?

    ticket_created = false # Flag to track ticket creation for "Checklist" level

    params[:groups].each do |group|
      group_id = group[:group]

      group[:questions].each_with_index do |qs, index|
        if qs[:id].present?
          # Update existing question

          question = @checklist.questions.find_by(id: qs[:id]) # Ensure you're using `find_by` in case the question doesn't exist
          if qs[:_destroy] == '1'
            question.destroy if question.present? # Only destroy if the question exists
          else
            # Update the question with new attributes
            question.update(
              name: qs[:name],
              help_text: qs[:help_text],
              qtype: qs[:type],
              option1: qs[:options][0],
              option2: qs[:options][1],
              option3: qs[:options][2],
              option4: qs[:options][3],
              value_type1: qs[:value_types][0],
              value_type2: qs[:value_types][1],
              value_type3: qs[:value_types][2],
              value_type4: qs[:value_types][3],
              question_mandatory: qs[:question_mandatory],
              image_mandatory: qs[:image_mandatory] == "1",
              help_text_enbled: qs[:help_text_enbled],
              rating: qs[:rating],
              weightage: qs[:weightage],
              reading: qs[:reading],
              group_id: group_id
            ) if question.present?
          end
        else
          # Create a new question only if no `id` is present
          question = @checklist.questions.create(
            group_id: group_id,
            name: qs[:name],
            help_text: qs[:help_text],
            qtype: qs[:type],
            option1: qs[:options][0],
            option2: qs[:options][1],
            option3: qs[:options][2],
            option4: qs[:options][3],
            value_type1: qs[:value_types][0],
            value_type2: qs[:value_types][1],
            value_type3: qs[:value_types][2],
            value_type4: qs[:value_types][3],
            question_mandatory: qs[:question_mandatory],
            image_mandatory: qs[:image_mandatory] == "1",
            help_text_enbled: qs[:help_text_enbled],
            rating: qs[:rating],
            weightage: qs[:weightage],
            reading: qs[:reading]
          )
        end

        # Handle image attachment for new or updated questions
        if qs["image_for_question #{index + 1}"].present?
          Attachfile.create(
            image: qs["image_for_question #{index + 1}"],
            relation: "QuestionHint",
            relation_id: question.id,
            active: 1
          )
        end

        # Handle ticket creation logic
        # if @checklist.ticket_enabled
        #   if @checklist.ticket_level_type == "Checklist" && !ticket_created
        #     # Checklist Level: Create one ticket if any question has type "N"
        #     if qs[:value_types].include?("N")
        #       Complaint.create(
        #         assigned_to: params[:assigned_to],
        #         issue_status: "Pending",
        #         priority: "High",
        #         heading: @checklist.try(:name),
        #         id_user: @checklist.user_id
        #       )
        #       ticket_created = true
        #     end
        #   elsif @checklist.ticket_level_type == "Question"
        #     # Question Level: Create a ticket for each question with type "N"
        #     if [qs[:value_types][0], qs[:value_types][1], qs[:value_types][2], qs[:value_types][3]].include?("N")
        #       Complaint.create(
        #         assigned_to: params[:assigned_to],
        #         issue_status: "Pending",
        #         priority: "High",
        #         heading: question.try(:name),
        #         id_user: @checklist.user_id
        #       )
        #     end
        #   end
        # end
      end
    end
  end



  # Use callbacks to share common setup or constraints between actions.
  def set_checklist
    @checklist = Checklist.unscoped.find_by_id(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def checklist_params
    params.require(:checklist).permit(:grace_period, :supplier_id, :is_approved, :group_id, :sub_group_id, :weightage_enabled, :company_id, :site_id, :frequency, :start_date, :end_date, :user_id, :grace_period_value, :grace_period_unit, :name, :occurs, :ctype, :priority_level,:ticket_level_type,:ticket_enabled,:category_id, :supervisior_id => [])
  end
end
