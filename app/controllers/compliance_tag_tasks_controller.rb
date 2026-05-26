class ComplianceTagTasksController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_compliance_tag_task, only: %i[ show edit update destroy ]

  # GET /compliance_tag_tasks or /compliance_tag_tasks.json
  def index
    @compliance_tag_tasks = ComplianceTagTask.ransack(params[:q]).result
  end

  # GET /compliance_tag_tasks/1 or /compliance_tag_tasks/1.json
  def show
  end

  # GET /compliance_tag_tasks/new
  def new
    @compliance_tag_task = ComplianceTagTask.new
  end

  # GET /compliance_tag_tasks/1/edit
  def edit
  end

  # POST /compliance_tag_tasks or /compliance_tag_tasks.json
  def create
  tasks_data = params[:compliance_tag_task] # Fix parameter extraction

  # Ensure tasks_data is a hash
  if tasks_data.is_a?(Hash)
    tasks_data.each do |_key, task_data|
      task_params = task_data.permit(:name, :weightage, :mandatory, :compliance_tag_id)

      @compliance_tag_task = ComplianceTagTask.new(task_params)

      if @compliance_tag_task.save
        # Handle attachments if present
        if task_data[:attachments].present?
          task_data[:attachments].each do |attachment|
            Attachfile.create(relation: "ComplianceTagTask", relation_id: @compliance_tag_task.id, image: attachment)
          end
        end
      else
        flash[:error] = "One or more tasks are invalid."
        render :new and return
      end
    end

    # If all tasks are created successfully, redirect to index
    respond_to do |format|
      format.html { redirect_to compliance_tag_tasks_path, notice: "Compliance tag tasks were successfully created." }
      format.json { render json: { message: "Compliance tag tasks were successfully created." }, status: :created }
    end
  else
    # Handle single task creation
    @compliance_tag_task = ComplianceTagTask.new(compliance_tag_task_params)
    respond_to do |format|
      if @compliance_tag_task.save
        if params[:attachments].present?
          params[:attachments].each do |attachment|
            Attachfile.create(relation: "ComplianceTagTask", relation_id: @compliance_tag_task.id, image: attachment)
          end
        end
        format.html { redirect_to @compliance_tag_task, notice: "Compliance tag task was successfully created." }
        format.json { render :show, status: :created, location: @compliance_tag_task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @compliance_tag_task.errors, status: :unprocessable_entity }
      end
    end
  end
end




  # PATCH/PUT /compliance_tag_tasks/1 or /compliance_tag_tasks/1.json
  def update
    respond_to do |format|
      if @compliance_tag_task.update(compliance_tag_task_params)
        format.html { redirect_to @compliance_tag_task, notice: "Compliance tag task was successfully updated." }
        format.json { render :show, status: :ok, location: @compliance_tag_task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compliance_tag_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compliance_tag_tasks/1 or /compliance_tag_tasks/1.json
  def destroy
    @compliance_tag_task.destroy
    respond_to do |format|
      format.html { redirect_to compliance_tag_tasks_url, notice: "Compliance tag task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compliance_tag_task
      @compliance_tag_task = ComplianceTagTask.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def compliance_tag_task_params
      params.require(:compliance_tag_task).permit(:name, :weightage,:mandatory, :compliance_tag_id)
    end
end
