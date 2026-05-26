class GroupsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_group, only: %i[ show edit update destroy ]

  # GET /groups or /groups.json
  def index
    @groups = Group.where(site_id:@user.current_site_id).order(created_at: :DESC)
  end

  # GET /groups/1 or /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)
    @group.created_by_id = @user.id
    @group.site_id = @user.current_site_id

    

    respond_to do |format|
      if @group.save
        if params[:group][:member_ids].present?
          params[:group][:member_ids].each do |user_id|
          GroupMember.create(group_id: @group.id, user_id: user_id, site_id: @user.current_site_id)
        end
        if params[:attachment].present?
          Attachfile.create(image: params[:attachment], relation: "UserGroup", relation_id: @group.id, active: 1)
        end
      end

        format.html { redirect_to @group, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
def update
  respond_to do |format|
    Group.transaction do
      if @group.update(group_params)
        # Update group members
        if params[:group][:member_ids].present?
          # Convert to array of integers for accurate comparison
          new_member_ids = params[:group][:member_ids].map(&:to_i)
          current_member_ids = @group.group_members.pluck(:user_id)

          # Add new members
          (new_member_ids - current_member_ids).each do |user_id|
            GroupMember.create(group_id: @group.id, user_id: user_id, site_id: @user.current_site_id)
          end

          # Remove members no longer in the list
          (current_member_ids - new_member_ids).each do |user_id|
            @group.group_members.find_by(user_id: user_id)&.destroy
          end
        end

        # Update attachment if provided
        if params[:attachment].present?
          attachfile = Attachfile.find_or_initialize_by(relation: "UserGroup", relation_id: @group.id)
          attachfile.update(image: params[:attachment], active: 1)
        end

        format.html { redirect_to @group, notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  rescue => e
    format.html { redirect_to @group, alert: "Failed to update group: #{e.message}" }
    format.json { render json: { error: e.message }, status: :unprocessable_entity }
  end
end


  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # DELETE /groups/destroy_multiple or /groups/destroy_multiple.json
  def destroy_multiple
    group_ids = params[:group_ids]

    # Ensure it's an array by parsing if needed (Rails should handle this automatically)
    group_ids = group_ids.split(',') if group_ids.is_a?(String)

    # Find the groups by their IDs
    groups = Group.where(id: group_ids)

    if groups.present?
      if groups.destroy_all
        respond_to do |format|
          format.html { redirect_to groups_url, notice: "Groups were successfully destroyed." }
          format.json { render json: { message: " Groups were successfully destroyed." }, status: :ok }
        end
      else
        respond_to do |format|
          format.html { redirect_to groups_url, alert: "There was an issue deleting the groups." }
          format.json { render json: { error: "There was an issue deleting the groups." }, status: :unprocessable_entity }
        end
      end
    else
      # Handle the case where no groups are found for the given IDs
      respond_to do |format|
        format.html { redirect_to groups_url, alert: "No groups found with the provided IDs." }
        format.json { render json: { error: "There were no groups with those IDs." }, status: :unprocessable_entity }
      end
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:group_name,:group_type, :group_admin, :group_roles, :group_permissions, :group_activities, :add_members, :group_description, :created_by_id)
    end
end
