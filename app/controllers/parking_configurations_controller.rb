class ParkingConfigurationsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_parking_configuration, only: %i[ show edit update destroy ]

  # GET /parking_configurations or /parking_configurations.json
  def index
    @q = ParkingConfiguration.ransack(params[:q])
    base_scope = @q.result.includes(:building, :site, :floor).where(site_id: @user.current_site_id).order(created_at: :desc)
    @parking_configurations = base_scope.page(params[:page]).per(params[:per_page] || 100)
  end

  # GET /parking_configurations/1 or /parking_configurations/1.json
  def show
  end

  # GET /parking_configurations/new
  def new
    @parking_configuration = ParkingConfiguration.new
  end

  # GET /parking_configurations/1/edit
  def edit
  end

  # POST /parking_configurations or /parking_configurations.json
  def create
    parking_data = if parking_params[:all_parking].present?
      parking_params[:all_parking]
    else
      [parking_configuration_params]
    end

    created_records = []

    ActiveRecord::Base.transaction do
      parking_data.each do |parking|
        record = ParkingConfiguration.new(parking)
        record.site_id = @user.current_site_id

        unless record.save
          render json: {
            error: "Parking configuration creation failed",
            details: record.errors.full_messages
          }, status: :unprocessable_entity

          raise ActiveRecord::Rollback
        end

        created_records << record
      end
    end

    respond_to do |format|
      format.html do
        redirect_to parking_configurations_path,
          notice: "#{created_records.count} parking configurations created successfully."
      end

      format.json do
        render json: {
          message: "Parking configurations created successfully",
          data: created_records
        }, status: :created
      end
    end
  end


  # PATCH/PUT /parking_configurations/1 or /parking_configurations/1.json
  def update
    respond_to do |format|
      if @parking_configuration.update(parking_configuration_params)
        format.html { redirect_to @parking_configuration, notice: "Parking configuration was successfully updated." }
        format.json { render :show, status: :ok, location: @parking_configuration }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @parking_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parking_configurations/1 or /parking_configurations/1.json
  def destroy
    @parking_configuration.destroy
    respond_to do |format|
      format.html { redirect_to parking_configurations_url, notice: "Parking configuration was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_parking_configuration
    @parking_configuration = ParkingConfiguration.find(params[:id])
  end
  def parking_params
    params.permit(all_parking: [:name, :building_id, :floor_id, :vehicle_type, :is_reserved, :reserved_for_user_id])
  end
  # Only allow a list of trusted parameters through.
  def parking_configuration_params
    params.require(:parking_configuration).permit(:name, :building_id, :floor_id, :vehicle_type,:is_reserved,:reserved_for_user_id,:site_id)
  end
end
