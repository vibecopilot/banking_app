class AssetGroupsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_asset_group, only: %i[ show edit update destroy ]

  # GET /asset_groups or /asset_groups.json
  def index
    @asset_groups = AssetGroup.where(company_id: @user.site.company_id).ransack(params[:q]).result
  end

  # GET /asset_groups/1 or /asset_groups/1.json
  def show
  end

  # GET /asset_groups/new
  def new
    @asset_group = AssetGroup.new
  end

  # GET /asset_groups/1/edit
  def edit
  end

  # POST /asset_groups or /asset_groups.json
  def create
    @asset_group = AssetGroup.new(asset_group_params)

    respond_to do |format|
      if @asset_group.save
        format.html { redirect_to @asset_group, notice: "Asset group was successfully created." }
        format.json { render :show, status: :created, location: @asset_group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @asset_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    @file = params[:file]
    @uploadds = AssetGroup.import(@file, @user)
    respond_to do |format|
      format.html {
        redirect_to request.referrer + "#" , notice: "Successfully imported Asset Groups"
      }
      format.json { render json: @uploadds }
    end
  end

  # PATCH/PUT /asset_groups/1 or /asset_groups/1.json
  def update
    respond_to do |format|
      if @asset_group.update(asset_group_params)
        format.html { redirect_to @asset_group, notice: "Asset group was successfully updated." }
        format.json { render :show, status: :ok, location: @asset_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @asset_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_groups/1 or /asset_groups/1.json
  def destroy
    @asset_group.destroy
    respond_to do |format|
      format.html { redirect_to asset_groups_url, notice: "Asset group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_group
      @asset_group = AssetGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def asset_group_params
      params.require(:asset_group).permit(:name, :description , :group_for, :company_id)
    end
end
