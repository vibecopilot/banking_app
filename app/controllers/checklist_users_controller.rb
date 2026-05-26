class ChecklistUsersController < ApplicationController
  before_action :set_checklist_user, only: %i[ show edit update destroy ]

  # GET /checklist_users or /checklist_users.json
  def index
    @checklist_users = ChecklistUser.all
  end

  # GET /checklist_users/1 or /checklist_users/1.json
  def show
  end

  # GET /checklist_users/new
  def new
    @checklist_user = ChecklistUser.new
  end

  # GET /checklist_users/1/edit
  def edit
  end

  # POST /checklist_users or /checklist_users.json
  def create
    @checklist_user = ChecklistUser.new(checklist_user_params)

    respond_to do |format|
      if @checklist_user.save
        format.html { redirect_to @checklist_user, notice: "Checklist user was successfully created." }
        format.json { render :show, status: :created, location: @checklist_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @checklist_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checklist_users/1 or /checklist_users/1.json
  def update
    respond_to do |format|
      if @checklist_user.update(checklist_user_params)
        format.html { redirect_to @checklist_user, notice: "Checklist user was successfully updated." }
        format.json { render :show, status: :ok, location: @checklist_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @checklist_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklist_users/1 or /checklist_users/1.json
  def destroy
    @checklist_user.destroy
    respond_to do |format|
      format.html { redirect_to checklist_users_url, notice: "Checklist user was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checklist_user
      @checklist_user = ChecklistUser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def checklist_user_params
      params.require(:checklist_user).permit(:resource_id, :checklist_id, :resource_type, :user_id)
    end
end
