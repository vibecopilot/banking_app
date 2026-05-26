class MomTasksController < ApplicationController
  before_action :set_mom_task, only: %i[ show edit update destroy ]

  # GET /mom_tasks or /mom_tasks.json
  def index
    @mom_tasks = MomTask.all
  end

  # GET /mom_tasks/1 or /mom_tasks/1.json
  def show
  end

  # GET /mom_tasks/new
  def new
    @mom_task = MomTask.new
  end

  # GET /mom_tasks/1/edit
  def edit
  end

  # POST /mom_tasks or /mom_tasks.json
  def create
    @mom_task = MomTask.new(mom_task_params)

    respond_to do |format|
      if @mom_task.save
        format.html { redirect_to @mom_task, notice: "Mom task was successfully created." }
        format.json { render :show, status: :created, location: @mom_task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mom_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mom_tasks/1 or /mom_tasks/1.json
  def update
    respond_to do |format|
      if @mom_task.update(mom_task_params)
        format.html { redirect_to @mom_task, notice: "Mom task was successfully updated." }
        format.json { render :show, status: :ok, location: @mom_task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mom_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mom_tasks/1 or /mom_tasks/1.json
  def destroy
    @mom_task.destroy
    respond_to do |format|
      format.html { redirect_to mom_tasks_url, notice: "Mom task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mom_task
      @mom_task = MomTask.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mom_task_params
      params.require(:mom_task).permit(:mom_detail_id, :description, :responsible_person_id, :target_date, :responsible_person_email, :responsible_person_type, :responsible_person_name, :company_tag_id)
    end
end
