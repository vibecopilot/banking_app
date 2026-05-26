class VehicleSetupsController < ApplicationController
  before_action :set_vehicle_setup, only: %i[ show edit update destroy ]

  # GET /vehicle_setups or /vehicle_setups.json
  def index
    @q = VehicleSetup.ransack(params[:q])
    @vehicle_setups = @q.result.order(created_at: :desc)
  end

  # GET /vehicle_setups/1 or /vehicle_setups/1.json
  def show
  end

  # GET /vehicle_setups/new
  def new
    @vehicle_setup = VehicleSetup.new
  end

  # GET /vehicle_setups/1/edit
  def edit
  end

  # POST /vehicle_setups or /vehicle_setups.json
  def create
    @vehicle_setup = VehicleSetup.new(vehicle_setup_params)

    respond_to do |format|
      if @vehicle_setup.save
        format.html { redirect_to @vehicle_setup, notice: "Vehicle setup was successfully created." }
        format.json { render :show, status: :created, location: @vehicle_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vehicle_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vehicle_setups/1 or /vehicle_setups/1.json
  def update
    respond_to do |format|
      if @vehicle_setup.update(vehicle_setup_params)
        format.html { redirect_to @vehicle_setup, notice: "Vehicle setup was successfully updated." }
        format.json { render :show, status: :ok, location: @vehicle_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vehicle_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vehicle_setups/1 or /vehicle_setups/1.json
  def destroy
    @vehicle_setup.destroy
    respond_to do |format|
      format.html { redirect_to vehicle_setups_url, notice: "Vehicle setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle_setup
      @vehicle_setup = VehicleSetup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def vehicle_setup_params
      params.require(:vehicle_setup).permit(:vehicle_category, :vehicle_type_name, :status)
    end
end
