class TmpChecklistsController < ApplicationController
  before_action :set_tmp_checklist, only: %i[ show edit update destroy ]

  # GET /tmp_checklists or /tmp_checklists.json
  def index
    @tmp_checklists = TmpChecklist.all
  end

  # GET /tmp_checklists/1 or /tmp_checklists/1.json
  def show
  end

  # GET /tmp_checklists/new
  def new
    @tmp_checklist = TmpChecklist.new
  end

  # GET /tmp_checklists/1/edit
  def edit
  end

  # POST /tmp_checklists or /tmp_checklists.json
  def create
    @tmp_checklist = TmpChecklist.new(tmp_checklist_params)

    respond_to do |format|
      if @tmp_checklist.save
        format.html { redirect_to @tmp_checklist, notice: "Tmp checklist was successfully created." }
        format.json { render :show, status: :created, location: @tmp_checklist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tmp_checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tmp_checklists/1 or /tmp_checklists/1.json
  def update
    respond_to do |format|
      if @tmp_checklist.update(tmp_checklist_params)
        format.html { redirect_to @tmp_checklist, notice: "Tmp checklist was successfully updated." }
        format.json { render :show, status: :ok, location: @tmp_checklist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tmp_checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tmp_checklists/1 or /tmp_checklists/1.json
  def destroy
    @tmp_checklist.destroy
    respond_to do |format|
      format.html { redirect_to tmp_checklists_url, notice: "Tmp checklist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tmp_checklist
      @tmp_checklist = TmpChecklist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tmp_checklist_params
      params.require(:tmp_checklist).permit(:site_id, :frequency, :user_id, :tmp_name, :occurs, :ctype, :patrolling_id, :weightage_enabled)
    end
end
