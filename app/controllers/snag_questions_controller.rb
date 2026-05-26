class SnagQuestionsController < ApplicationController
  before_action :set_snag_question, only: %i[ show edit update destroy ]

  # GET /snag_questions or /snag_questions.json
  def index
    @snag_questions = SnagQuestion.all
  end

  # GET /snag_questions/1 or /snag_questions/1.json
  def show
  end

  # GET /snag_questions/new
  def new
    @snag_question = SnagQuestion.new
  end
  
  # GET /snag_questions/1/edit
  def edit
  end

  # POST /snag_questions or /snag_questions.json
  def create
    @snag_question = SnagQuestion.new(snag_question_params)

    respond_to do |format|
      if @snag_question.save
        format.html { redirect_to @snag_question, notice: "Snag question was successfully created." }
        format.json { render :show, status: :created, location: @snag_question }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @snag_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /snag_questions/1 or /snag_questions/1.json
  def update
    respond_to do |format|
      if @snag_question.update(snag_question_params)
        format.html { redirect_to @snag_question, notice: "Snag question was successfully updated." }
        format.json { render :show, status: :ok, location: @snag_question }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @snag_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snag_questions/1 or /snag_questions/1.json
  def destroy
    @snag_question.destroy
    respond_to do |format|
      format.html { redirect_to snag_questions_url, notice: "Snag question was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snag_question
      @snag_question = SnagQuestion.find(params[:id])
    end

    def snag_question_params
      params.require(:snag_question).permit(:qtype, :descr, :checklist_id, :user_id, :img_mandatory, :quest_mandatory, :active, :company_id, :qnumber)
    end
end
