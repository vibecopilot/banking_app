class PollUsersController < ApplicationController
  before_action :set_poll_user, only: %i[ show edit update destroy ]

  # GET /poll_users or /poll_users.json
  def index
    @poll_users = PollUser.all
  end

  # GET /poll_users/1 or /poll_users/1.json
  def show
  end

  # GET /poll_users/new
  def new
    @poll_user = PollUser.new
  end

  # GET /poll_users/1/edit
  def edit
  end

  # POST /poll_users or /poll_users.json
  def create
    @poll_user = PollUser.new(poll_user_params)

    respond_to do |format|
      if @poll_user.save
        format.html { redirect_to @poll_user, notice: "Poll user was successfully created." }
        format.json { render :show, status: :created, location: @poll_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @poll_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /poll_users/1 or /poll_users/1.json
  def update
    respond_to do |format|
      if @poll_user.update(poll_user_params)
        format.html { redirect_to @poll_user, notice: "Poll user was successfully updated." }
        format.json { render :show, status: :ok, location: @poll_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @poll_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /poll_users/1 or /poll_users/1.json
  def destroy
    @poll_user.destroy
    respond_to do |format|
      format.html { redirect_to poll_users_url, notice: "Poll user was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll_user
      @poll_user = PollUser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def poll_user_params
      params.require(:poll_user).permit(:poll_id, :user_id)
    end
end
