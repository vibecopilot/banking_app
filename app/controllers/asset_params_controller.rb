class AssetParamsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_asset_param, only: %i[ show edit update destroy ]

  # GET /asset_params or /asset_params.json
  def index
    @asset_params = AssetParam.all
  end

  # GET /asset_params/1 or /asset_params/1.json
  def show
  end

  # GET /asset_params/new
  def new
    @asset_param = AssetParam.new
  end

  # GET /asset_params/1/edit
  def edit
  end

  # POST /asset_params or /asset_params.json
  def create
    @asset_param = AssetParam.new(asset_param_params)

    respond_to do |format|
      if @asset_param.save
        format.html { redirect_to "/site_assets/#{@asset_param.asset_id}", notice: "Asset param was successfully created." }
        format.json { render :show, status: :created, location: @asset_param }
      else
        format.html { redirect_to "/site_assets/#{@asset_param.asset_id}", notice: @asset_param.errors.full_messages.join(", ") }
        format.json { render json: @asset_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asset_params/1 or /asset_params/1.json
  def update
    respond_to do |format|
      if @asset_param.update(asset_param_params)
        format.html { redirect_to @asset_param.site_asset, notice: "Asset param was successfully updated." }
        format.json { render :show, status: :ok, location: @asset_param }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @asset_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_params/1 or /asset_params/1.json
  def destroy
    @asset_param.destroy
    respond_to do |format|
      format.html { redirect_to asset_params_url, notice: "Asset param was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_param
      @asset_param = AssetParam.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def asset_param_params
      params.require(:asset_param).permit(:asset_id, :name, :param_type, :dashboard_view, :consumption_view, :order, :alert_below, :alert_above, :min_val, :digit, :max_val, :check_prev,:multiplier_factor, :unit_type)
    end
end
