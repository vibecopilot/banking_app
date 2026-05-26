class AssetMeasuresController < ApplicationController
  before_action :set_asset_measure, only: %i[ show edit update destroy ]

  # GET /asset_measures or /asset_measures.json
  def index
    @asset_measures = AssetMeasure.all
  end

  # GET /asset_measures/1 or /asset_measures/1.json
  def show
  end

  # GET /asset_measures/new
  def new
    @asset_measure = AssetMeasure.new
  end

  # GET /asset_measures/1/edit
  def edit
  end

  # POST /asset_measures or /asset_measures.json
  def create
    @asset_measure = AssetMeasure.new(asset_measure_params)

    respond_to do |format|
      if @asset_measure.save
        format.html { redirect_to @asset_measure, notice: "Asset measure was successfully created." }
        format.json { render :show, status: :created, location: @asset_measure }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @asset_measure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asset_measures/1 or /asset_measures/1.json
  def update
    respond_to do |format|
      if @asset_measure.update(asset_measure_params)
        format.html { redirect_to @asset_measure, notice: "Asset measure was successfully updated." }
        format.json { render :show, status: :ok, location: @asset_measure }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @asset_measure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_measures/1 or /asset_measures/1.json
  def destroy
    @asset_measure.destroy
    respond_to do |format|
      format.html { redirect_to asset_measures_url, notice: "Asset measure was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_measure
      @asset_measure = AssetMeasure.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def asset_measure_params
      params.require(:asset_measure).permit(:asset_id, :name, :min_value, :max_value, :alert_below, :alert_above, :active, :unit_type, :multiplier_factor, :meter_tag, :meter_unit_id, :cloned, :check_previous_reading)
    end
end
