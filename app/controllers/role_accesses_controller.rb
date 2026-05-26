class RoleAccessesController < ApplicationController
  before_action :set_role_access, only: %i[ show edit update destroy ]

  # GET /role_accesses or /role_accesses.json
  def index
    @role_accesses = RoleAccess.all
  end

  # GET /role_accesses/1 or /role_accesses/1.json
  def show
  end

  # GET /role_accesses/new
  def new
    @role_access = RoleAccess.new
  end

  # GET /role_accesses/1/edit
  def edit
  end

  # POST /role_accesses or /role_accesses.json
  # def create
  #   @role_access = RoleAccess.new(role_access_params)
  #   # binding.pry
  #   respond_to do |format|
  #     if @role_access.save
  #       format.html { redirect_to @role_access, notice: "Role access was successfully created." }
  #       format.json { render :show, status: :created, location: @role_access }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @role_access.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def create
    @role_access = RoleAccess.new(
      title: params[:role_access][:title],
      site_id: params[:role_access][:site_id]
    )

    begin
      ActiveRecord::Base.transaction do
        @role_access.save!
        create_permissions(@role_access)
      end

      respond_to do |format|
        format.html { redirect_to @role_access, notice: "Role access was successfully created." }
        format.json { render json: @role_access, status: :created }
      end

    rescue => e
      respond_to do |format|
        format.html { redirect_to role_accesses_path, alert: e.message }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /role_accesses/1 or /role_accesses/1.json
  def update
    respond_to do |format|
      if @role_access.update(role_access_params)
        format.html { redirect_to @role_access, notice: "Role access was successfully updated." }
        format.json { render :show, status: :ok, location: @role_access }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @role_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /role_accesses/1 or /role_accesses/1.json
  def destroy
    @role_access.destroy

    respond_to do |format|
      format.html { redirect_to role_accesses_path, status: :see_other, notice: "Role access was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def create_permissions(role)
    # binding.pry
    @site_id = params[:role_access][:site_id]
    params[:role_access][:permissions_attributes].each do |perm|
      feature = Feature.find_by(feature_name: perm[:feature], site_id: @site_id)

      unless feature
        rails ActiveRecord::Rollback, "Feature '#{perm[:feature]}' not found for the site"
      end

      if role.permissions.exists?(feature: perm[:feature])
        rails ActiveRecord::Rollback, "permissions already exists for feature '#{perm[:feature]}'"
      end

      role.permissions.create!(
        # role_modules_id: mod.id,
        feature: perm[:feature],
        can_create: perm[:can_create],
        can_view: perm[:can_view],
        can_update: perm[:can_update],
        can_delete: perm[:can_delete]
      )
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_role_access
    @role_access = RoleAccess.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def role_access_params
    params.require(:role_access).permit(
      :title,
      :site_id,
      permissions_attributes: [
        :id,
        :role_modules_id,
        :feature,
        :can_create,
        :can_view,
        :can_update,
        :can_delete,
        :_destroy
      ]
    )
  end
end
