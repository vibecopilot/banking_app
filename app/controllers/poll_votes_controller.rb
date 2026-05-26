class PollVotesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user 
  before_action :set_user
  before_action :set_poll_vote, only: %i[ show edit update destroy ]

  # GET /poll_votes or /poll_votes.json
  def index
    @poll_votes = PollVote.all
  end

  # GET /poll_votes/1 or /poll_votes/1.json
  def show
  end

  # GET /poll_votes/new
  def new
    @poll_vote = PollVote.new
  end

  # GET /poll_votes/1/edit
  def edit
  end

  # POST /poll_votes or /poll_votes.json
  def create
    @poll = Poll.find(params[:poll_id])
    @poll_vote = @poll.poll_votes.new(poll_vote_params)
    @poll_vote.poll_user_id = @user.id

    respond_to do |format|
      if @poll.active?
        if @poll_vote.save
          format.html { redirect_to @poll, notice: "Your vote was successfully recorded." }
          format.json { render :show, status: :created, location: @poll_vote }
        else
          format.html { redirect_to @poll, alert: @poll_vote.errors.full_messages.join(", ") }
          format.json { render json: @poll_vote.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to @poll, alert: "This poll is not currently active." }
        format.json { render json: { error: "This poll is not currently active." }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /poll_votes/1 or /poll_votes/1.json
  def update
    respond_to do |format|
      if @poll_vote.update(poll_vote_params)
        format.html { redirect_to @poll_vote, notice: "Poll vote was successfully updated." }
        format.json { render :show, status: :ok, location: @poll_vote }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @poll_vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /poll_votes/1 or /poll_votes/1.json
  def destroy
    @poll_vote.destroy
    respond_to do |format|
      format.html { redirect_to poll_votes_url, notice: "Poll vote was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll_vote
      @poll_vote = PollVote.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def poll_vote_params
      params.require(:poll_vote).permit(:poll_option_id)
    end
end
