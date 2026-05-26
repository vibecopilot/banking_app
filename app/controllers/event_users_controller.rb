class EventUsersController < ApplicationController
  before_action :set_event_user, only: %i[ show edit update destroy ]

  # GET /event_users or /event_users.json

def index
  @q = EventUser.ransack(params[:q])
  scoped = @q.result

  scoped = scoped.where(user_id: params[:user_id]) if params[:user_id].present?

  if params[:rmb] == "true"
    scoped = scoped.joins(:user).where(users: { current_site_id: 68 })
  end

  @event_users = scoped.order(created_at: :desc)
                       .paginate(page: params[:page], per_page: params[:per_page] || 20)

 # @event_users = EventUser.joins(:user).where(users: { current_site_id: 68 }).order(created_at: :desc).page(params[:page]).per(20)                     

  respond_to do |format|
    format.html
    format.json { render 'index' }
  end
end



  # GET /event_users/1 or /event_users/1.json
  def show
  end

  # GET /event_users/new
  def new
    @event_user = EventUser.new
  end

  # GET /event_users/1/edit
  def edit
  end

  # POST /event_users or /event_users.json
  def create
    @event_user = EventUser.new(event_user_params)

    respond_to do |format|
      if @event_user.save
        format.html { redirect_to @event_user, notice: "Event user was successfully created." }
        format.json { render :show, status: :created, location: @event_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_users/1 or /event_users/1.json
  def update
    respond_to do |format|
      if @event_user.update(event_user_params)
        format.html { redirect_to @event_user, notice: "Event user was successfully updated." }
        format.json { render :show, status: :ok, location: @event_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_users/1 or /event_users/1.json
  def destroy
    @event_user.destroy
    respond_to do |format|
      format.html { redirect_to event_users_url, notice: "Event user was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_user
      @event_user = EventUser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_user_params
      params.require(:event_user).permit(:event_id,:event_guest_id, :user_id, :rsvp)
    end
end
