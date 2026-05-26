class SubGroupsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_sub_group, only: %i[ show edit update destroy ]

  # GET /sub_groups or /sub_groups.json
  def index
    if params[:group_id].present?
      @sub_groups = SubGroup.where(group_id: params[:group_id])
    else
      @sub_groups = SubGroup.ransack(asset_group_company_id_eq: @user.site.company_id).result
    end
  end

  # GET /sub_groups/1 or /sub_groups/1.json
  def show
  end

  # GET /sub_groups/new
  def new
    @sub_group = SubGroup.new
  end

  # GET /sub_groups/1/edit
  def edit
  end

  # POST /sub_groups or /sub_groups.json
  def create
    @sub_group = SubGroup.new(sub_group_params)

    respond_to do |format|
      if @sub_group.save
        format.html { redirect_to @sub_group, notice: "Sub group was successfully created." }
        format.json { render :show, status: :created, location: @sub_group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sub_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sub_groups/1 or /sub_groups/1.json
  def update
    respond_to do |format|
      if @sub_group.update(sub_group_params)
        format.html { redirect_to @sub_group, notice: "Sub group was successfully updated." }
        format.json { render :show, status: :ok, location: @sub_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sub_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sub_groups/1 or /sub_groups/1.json
  def destroy
    @sub_group.destroy
    respond_to do |format|
      format.html { redirect_to sub_groups_url, notice: "Sub group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sub_group
      @sub_group = SubGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sub_group_params
      params.require(:sub_group).permit(:group_id, :name)
    end
end
