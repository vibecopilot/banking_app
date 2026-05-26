class SnagChecklistsController < ApplicationController
  before_action :set_snag_checklist, only: %i[ show edit update destroy ]

  # GET /snag_checklists or /snag_checklists.json
 def index
  @q = SnagChecklist.ransack(params[:q])
  @snag_checklists = @q.result.order(created_at: :desc)
end


  # GET /snag_checklists/1 or /snag_checklists/1.json
  def show
  end

  # GET /snag_checklists/new
  def new
    @snag_checklist = SnagChecklist.new
  end

  # GET /snag_checklists/1/edit
  def edit
  end

  # POST /snag_checklists or /snag_checklists.json
  # 
  # def create
  #   @snag_checklist = SnagChecklist.new(snag_checklist_params)
  #   respond_to do |format|
  #     if @snag_checklist.save
  #       if params[:question].present?
  #         params[:question].each do |snag_question|
  #           SnagQuestion.create()
  #           snag_question[:options].present?
  #             snag_question[:options].each do |option|
  #               SnagQuestOption.create()
  #             end
  #           end
  #         end
  #       end
  #       format.html { redirect_to @snag_checklist, notice: "Snag checklist was successfully created." }
  #       format.json { render :show, status: :created, location: @snag_checklist }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @snag_checklist.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def create
    # binding.pry
  @snag_checklist = SnagChecklist.new(snag_checklist_params)
  if @snag_checklist.save
    redirect_to @snag_checklist, notice: "Snag checklist was successfully created."
  else
    render :new, status: :unprocessable_entity
  end
end


  # PATCH/PUT /snag_checklists/1 or /snag_checklists/1.json
  def update
    respond_to do |format|
      if @snag_checklist.update(snag_checklist_params)
        format.html { redirect_to @snag_checklist, notice: "Snag checklist was successfully updated." }
        format.json { render :show, status: :ok, location: @snag_checklist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @snag_checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snag_checklists/1 or /snag_checklists/1.json
  def destroy
    @snag_checklist.destroy
    respond_to do |format|
      format.html { redirect_to snag_checklists_url, notice: "Snag checklist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snag_checklist
      @snag_checklist = SnagChecklist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def snag_checklist_params
      params.require(:snag_checklist).permit(
      :name, :snag_audit_category_id, :snag_audit_sub_category_id, :active,
      :site_id, :company_id, :check_type, :user_id, :resource_id, :resource_type,
      snag_questions_attributes: [
        :qnumber, :qtype, :descr,:snag_checklist_id, :img_mandatory, :quest_mandatory, :active,
        { snag_quest_options_attributes: [:question_id, :snag_question_id,:qname, :active, :company_id, :option_type] }
      ]
    )
    end
end
