class ChecklistCronsController < ApplicationController
  before_action :set_checklist_cron, only: %i[ show edit update destroy ]

  # GET /checklist_crons or /checklist_crons.json
  def index
    @checklist_crons = ChecklistCron.all
  end

  # GET /checklist_crons/1 or /checklist_crons/1.json
  def show
  end

  # GET /checklist_crons/new
  def new
    @checklist_cron = ChecklistCron.new
  end

  # GET /checklist_crons/1/edit
  def edit
  end

  # POST /checklist_crons or /checklist_crons.json
  def create
    @checklist_cron = ChecklistCron.new(checklist_cron_params)

    respond_to do |format|
      if @checklist_cron.save
        format.html { redirect_to @checklist_cron, notice: "Checklist cron was successfully created." }
        format.json { render :show, status: :created, location: @checklist_cron }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @checklist_cron.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checklist_crons/1 or /checklist_crons/1.json
  def update
    respond_to do |format|
      if @checklist_cron.update(checklist_cron_params)
        format.html { redirect_to @checklist_cron, notice: "Checklist cron was successfully updated." }
        format.json { render :show, status: :ok, location: @checklist_cron }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @checklist_cron.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklist_crons/1 or /checklist_crons/1.json
  def destroy
    @checklist_cron.destroy
    respond_to do |format|
      format.html { redirect_to checklist_crons_url, notice: "Checklist cron was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checklist_cron
      @checklist_cron = ChecklistCron.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def checklist_cron_params
      params.require(:checklist_cron).permit(:checklist_id, :expression)
    end
end
