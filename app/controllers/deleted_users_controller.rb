class DeletedUsersController < ApplicationController
  before_action :set_deleted_user, only: %i[ show edit update destroy ]

  # GET /deleted_users or /deleted_users.json
  def index
    @deleted_users = DeletedUser.all
  end

  # GET /deleted_users/1 or /deleted_users/1.json
  def show
  end

  # GET /deleted_users/new
  def new
    @deleted_user = DeletedUser.new
  end

  # GET /deleted_users/1/edit
  def edit
  end

  # POST /deleted_users or /deleted_users.json
  def create
    @deleted_user = DeletedUser.new(deleted_user_params)

    respond_to do |format|
      if @deleted_user.save
        format.html { redirect_to @deleted_user, notice: "Deleted user was successfully created." }
        format.json { render :show, status: :created, location: @deleted_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @deleted_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deleted_users/1 or /deleted_users/1.json
  def update
    respond_to do |format|
      if @deleted_user.update(deleted_user_params)
        format.html { redirect_to @deleted_user, notice: "Deleted user was successfully updated." }
        format.json { render :show, status: :ok, location: @deleted_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @deleted_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deleted_users/1 or /deleted_users/1.json
  def destroy
    @deleted_user.destroy
    respond_to do |format|
      format.html { redirect_to deleted_users_url, notice: "Deleted user was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deleted_user
      @deleted_user = DeletedUser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def deleted_user_params
      params.require(:deleted_user).permit(:email, :mobile, :first_name, :last_name)
    end
end
