class AuditTasksController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_audit_task, only: %i[ show edit update destroy ]

  # GET /audit_tasks or /audit_tasks.json
  def index
    @q = AuditTask.ransack(params[:q])
    base_scope = @q.result.joins(:audit).where(audits: {site_id: @user.current_site_id})
    @audit_tasks = base_scope.page(params[:page]).per(params[:per_page] || 100)
  end

  # GET /audit_tasks/1 or /audit_tasks/1.json
  def show
  end

  # GET /audit_tasks/new
  def new
    @audit_task = AuditTask.new
  end

  # GET /audit_tasks/1/edit
  def edit
  end

  # POST /audit_tasks or /audit_tasks.json
  def create
    @audit_task = AuditTask.new(audit_task_params)

    respond_to do |format|
      if @audit_task.save
        format.html { redirect_to @audit_task, notice: "Audit task was successfully created." }
        format.json { render :show, status: :created, location: @audit_task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @audit_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /audit_tasks/1 or /audit_tasks/1.json
  def update
    respond_to do |format|
      if @audit_task.update(audit_task_params)
        format.html { redirect_to @audit_task, notice: "Audit task was successfully updated." }
        format.json { render :show, status: :ok, location: @audit_task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @audit_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /audit_tasks/1 or /audit_tasks/1.json
  def destroy
    @audit_task.destroy
    respond_to do |format|
      format.html { redirect_to audit_tasks_url, notice: "Audit task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_audit_task
      @audit_task = AuditTask.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def audit_task_params
      params.require(:audit_task).permit(:group, :sub_group, :task, :input_type, :mandatory, :reading, :help_text, :weightage, :rating, :audit_id, :created_by_id)
    end
end
