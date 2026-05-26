class PollsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_poll, only: %i[ show edit update destroy ]

  # GET /polls or /polls.json
  def index
    @q = Poll.ransack(params[:q])
    base_scope = @q.result.joins(:user).where(users: { current_site_id: @user.current_site_id }).preload(:poll_options, :poll_votes, :poll_users, :user, :group)

    @polls = base_scope.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100 )
  end

  # GET /polls/1 or /polls/1.json
  def show
  end

  # GET /polls/new
  def new
    @poll = Poll.new
    @poll.poll_options.build
  end

  # GET /polls/1/edit
  def edit
  end

  # POST /polls or /polls.json
  def create
    @poll = Poll.new(poll_params)
    @poll.created_by_id = @user.id
    # binding.pry
    respond_to do |format|
      if @poll.save
        # binding.pry
        if params[:poll][:user_ids].present?
          user_ids = params[:poll][:user_ids].split(',')
          user_ids.each do |user_id|
            PollUser.create(user_id: user_id , poll_id: @poll.id)
          end
        end

        if @poll.send_mail.present?
          @poll.send_poll_notification
        end

        format.html { redirect_to @poll, notice: "Poll was successfully created." }
        format.json { render :show, status: :created, location: @poll }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @poll.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /polls/1 or /polls/1.json
  def update
    respond_to do |format|
      if @poll.update(poll_params)
        format.html { redirect_to @poll, notice: "Poll was successfully updated." }
        format.json { render :show, status: :ok, location: @poll }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @poll.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /polls/1 or /polls/1.json
  def destroy
    @poll.destroy
    respond_to do |format|
      format.html { redirect_to polls_url, notice: "Poll was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Mark poll as read for current user
  def mark_as_read
    poll_user = PollUser.find_by(poll_id: params[:id], user_id: @user.id)
    if poll_user
      poll_user.mark_as_read!
      render json: { success: true, message: "Poll marked as read" }
    else
      render json: { success: false, message: "Poll not found for user" }, status: :not_found
    end
  end

  # Mark poll as archived for current user
  def mark_as_archived
    poll_user = PollUser.find_by(poll_id: params[:id], user_id: @user.id)
    if poll_user
      poll_user.mark_as_archived!
      render json: { success: true, message: "Poll archived" }
    else
      render json: { success: false, message: "Poll not found for user" }, status: :not_found
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_poll
    @poll = Poll.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def poll_params
    params.require(:poll).permit(:title,:shared,:group_name,:send_mail,:group_id,:end_time,:start_time,:share_with,  :description, :start_date, :end_date, :visibility, :target_groups, :created_by_id,
                                 poll_options_attributes: [:id, :content, :_destroy],
                                 poll_users_attributes: [:id, :user_id, :read, :archived, :_destroy])
  end
end
