class SnagQuestOptionsController < ApplicationController
  before_action :set_snag_quest_option, only: %i[ show edit update destroy ]

  # GET /snag_quest_options or /snag_quest_options.json
  def index
    @snag_quest_options = SnagQuestOption.all
  end

  # GET /snag_quest_options/1 or /snag_quest_options/1.json
  def show
  end

  # GET /snag_quest_options/new
  def new
    @snag_quest_option = SnagQuestOption.new
  end

  # GET /snag_quest_options/1/edit
  def edit
  end

  # POST /snag_quest_options or /snag_quest_options.json
  def create
    @snag_quest_option = SnagQuestOption.new(snag_quest_option_params)

    respond_to do |format|
      if @snag_quest_option.save
        format.html { redirect_to @snag_quest_option, notice: "Snag quest option was successfully created." }
        format.json { render :show, status: :created, location: @snag_quest_option }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @snag_quest_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /snag_quest_options/1 or /snag_quest_options/1.json
  def update
    respond_to do |format|
      if @snag_quest_option.update(snag_quest_option_params)
        format.html { redirect_to @snag_quest_option, notice: "Snag quest option was successfully updated." }
        format.json { render :show, status: :ok, location: @snag_quest_option }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @snag_quest_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snag_quest_options/1 or /snag_quest_options/1.json
  def destroy
    @snag_quest_option.destroy
    respond_to do |format|
      format.html { redirect_to snag_quest_options_url, notice: "Snag quest option was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snag_quest_option
      @snag_quest_option = SnagQuestOption.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def snag_quest_option_params
      params.require(:snag_quest_option).permit(:question_id, :snag_question_id, :qname, :active, :company_id, :option_type)
    end
end
