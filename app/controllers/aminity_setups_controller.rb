class AminitySetupsController < ApplicationController
  before_action :set_aminity_setup, only: %i[ show edit update destroy ]

  # GET /aminity_setups or /aminity_setups.json
  def index
    @aminity_setups = AminitySetup.all
  end

  # GET /aminity_setups/1 or /aminity_setups/1.json
  def show
  end

  # GET /aminity_setups/new
  def new
    @aminity_setup = AminitySetup.new
  end

  # GET /aminity_setups/1/edit
  def edit
  end

  # POST /aminity_setups or /aminity_setups.json
  def create
    @aminity_setup = AminitySetup.new(aminity_setup_params)

    respond_to do |format|
      if @aminity_setup.save
        format.html { redirect_to @aminity_setup, notice: "Aminity setup was successfully created." }
        format.json { render :show, status: :created, location: @aminity_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @aminity_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aminity_setups/1 or /aminity_setups/1.json
  def update
    respond_to do |format|
      if @aminity_setup.update(aminity_setup_params)
        format.html { redirect_to @aminity_setup, notice: "Aminity setup was successfully updated." }
        format.json { render :show, status: :ok, location: @aminity_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @aminity_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aminity_setups/1 or /aminity_setups/1.json
  def destroy
    @aminity_setup.destroy
    respond_to do |format|
      format.html { redirect_to aminity_setups_url, notice: "Aminity setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aminity_setup
      @aminity_setup = AminitySetup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def aminity_setup_params
      params.require(:aminity_setup).permit(:aminity_id, :name, :site_id, :unit_id, :start_time, :end_time, :slot_frequency, :max_bookings_per_week)
    end
end
