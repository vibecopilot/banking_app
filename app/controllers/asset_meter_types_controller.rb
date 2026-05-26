class AssetMeterTypesController < ApplicationController
  before_action :set_asset_meter_type, only: %i[ show edit update destroy ]

  # GET /asset_meter_types or /asset_meter_types.json
  def index
    @asset_meter_types = AssetMeterType.all
  end

  # GET /asset_meter_types/1 or /asset_meter_types/1.json
  def show
  end

  # GET /asset_meter_types/new
  def new
    @asset_meter_type = AssetMeterType.new
  end

  # GET /asset_meter_types/1/edit
  def edit
  end

  # POST /asset_meter_types or /asset_meter_types.json
  def create
    @asset_meter_type = AssetMeterType.new(asset_meter_type_params)

    respond_to do |format|
      if @asset_meter_type.save
        format.html { redirect_to @asset_meter_type, notice: "Asset meter type was successfully created." }
        format.json { render :show, status: :created, location: @asset_meter_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @asset_meter_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asset_meter_types/1 or /asset_meter_types/1.json
  def update
    respond_to do |format|
      if @asset_meter_type.update(asset_meter_type_params)
        format.html { redirect_to @asset_meter_type, notice: "Asset meter type was successfully updated." }
        format.json { render :show, status: :ok, location: @asset_meter_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @asset_meter_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_meter_types/1 or /asset_meter_types/1.json
  def destroy
    @asset_meter_type.destroy
    respond_to do |format|
      format.html { redirect_to asset_meter_types_url, notice: "Asset meter type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_meter_type
      @asset_meter_type = AssetMeterType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def asset_meter_type_params
      params.require(:asset_meter_type).permit(:name, :value, :active, :unit_name)
    end
end
