class NoticeUsersController < ApplicationController
  before_action :set_notice_user, only: %i[ show edit update destroy ]

  # GET /notice_users or /notice_users.json
  def index
    if params[:user_id].present?
      @notice_users = NoticeUser.where(user_id: params[:user_id])
      else
      @notice_users = NoticeUser.all
    end
  end

  # GET /notice_users/1 or /notice_users/1.json
  def show
  end

  # GET /notice_users/new
  def new
    @notice_user = NoticeUser.new
  end

  # GET /notice_users/1/edit
  def edit
  end

  # POST /notice_users or /notice_users.json
  def create
    @notice_user = NoticeUser.new(notice_user_params)

    respond_to do |format|
      if @notice_user.save
        format.html { redirect_to @notice_user, notice: "Notice user was successfully created." }
        format.json { render :show, status: :created, location: @notice_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @notice_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notice_users/1 or /notice_users/1.json
  def update
    respond_to do |format|
      if @notice_user.update(notice_user_params)
        format.html { redirect_to @notice_user, notice: "Notice user was successfully updated." }
        format.json { render :show, status: :ok, location: @notice_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @notice_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notice_users/1 or /notice_users/1.json
  def destroy
    @notice_user.destroy
    respond_to do |format|
      format.html { redirect_to notice_users_url, notice: "Notice user was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notice_user
      @notice_user = NoticeUser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def notice_user_params
      params.require(:notice_user).permit(:notice_id, :user_id)
    end
end
