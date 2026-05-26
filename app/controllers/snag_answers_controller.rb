class SnagAnswersController < ApplicationController
  before_action :set_snag_answer, only: %i[ show edit update destroy ]

  # GET /snag_answers or /snag_answers.json
  def index
    # binding.pry
    @snag_answers = SnagAnswer.ransack(params[:q]).result
  end


  # GET /snag_answers/1 or /snag_answers/1.json
  def show
  end

  # GET /snag_answers/new
  def new
    @snag_answer = SnagAnswer.new
  end

  # GET /snag_answers/1/edit
  def edit
  end

  # POST /snag_answers or /snag_answers.json
  def create
    @snag_answer = SnagAnswer.new(snag_answer_params)

    respond_to do |format|
      if @snag_answer.save
        format.html { redirect_to @snag_answer, notice: "Snag answer was successfully created." }
        format.json { render :show, status: :created, location: @snag_answer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @snag_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /snag_answers/1 or /snag_answers/1.json
  def update
    respond_to do |format|
      if @snag_answer.update(snag_answer_params)
        format.html { redirect_to @snag_answer, notice: "Snag answer was successfully updated." }
        format.json { render :show, status: :ok, location: @snag_answer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @snag_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snag_answers/1 or /snag_answers/1.json
  def destroy
    @snag_answer.destroy
    respond_to do |format|
      format.html { redirect_to snag_answers_url, notice: "Snag answer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snag_answer
      @snag_answer = SnagAnswer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def snag_answer_params
      params.require(:snag_answer).permit(:question_id, :quest_option_id, :resource_type, :resource_id ,:ans_descr, :comments, :user_id, :company_id, :checklist_id, :answer_type, :answer_mode)
    end
end
