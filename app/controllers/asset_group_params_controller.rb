class AssetGroupParamsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_asset_group_param, only: %i[ show edit update destroy ]

  # GET /asset_group_params or /asset_group_params.json
  def index
    @asset_group_params = AssetGroupParam.all
  end

  # GET /asset_group_params/1 or /asset_group_params/1.json
  def show
  end

  # GET /asset_group_params/new
  def new
    @asset_group_param = AssetGroupParam.new
  end

  # GET /asset_group_params/1/edit
  def edit
  end

  # POST /asset_group_params or /asset_group_params.json
  def create
    @asset_group_param = AssetGroupParam.new(asset_group_param_params)

    respond_to do |format|
      if @asset_group_param.save
        format.html { redirect_to @asset_group_param.asset_group, notice: "Asset group param was successfully created." }
        format.json { render :show, status: :created, location: @asset_group_param }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @asset_group_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asset_group_params/1 or /asset_group_params/1.json
  def update
    respond_to do |format|
      if @asset_group_param.update(asset_group_param_params)
        format.html { redirect_to @asset_group_param.asset_group, notice: "Asset group param was successfully updated." }
        format.json { render :show, status: :ok, location: @asset_group_param }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @asset_group_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_group_params/1 or /asset_group_params/1.json
  def destroy
    @asset_group_param.destroy
    respond_to do |format|
      format.html { redirect_to asset_groups_url, notice: "Asset group param was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_group_param
      @asset_group_param = AssetGroupParam.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def asset_group_param_params
      params.require(:asset_group_param).permit(:name, :order, :dashboard_view, :consumption_view, :asset_group_id)
    end
end
