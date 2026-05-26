class PermitActivitySetupsController < ApplicationController
  before_action :set_permit_activity_setup, only: %i[ show edit update destroy ]

  # GET /permit_activity_setups or /permit_activity_setups.json
  def index
    @permit_activity_setups = PermitActivitySetup.all
  end

  # GET /permit_activity_setups/1 or /permit_activity_setups/1.json
  def show
  end

  # GET /permit_activity_setups/new
  def new
    @permit_activity_setup = PermitActivitySetup.new
  end

  # GET /permit_activity_setups/1/edit
  def edit
  end

  # POST /permit_activity_setups or /permit_activity_setups.json
  def create
    @permit_activity_setup = PermitActivitySetup.new(permit_activity_setup_params)

    respond_to do |format|
      if @permit_activity_setup.save
        format.html { redirect_to @permit_activity_setup, notice: "Permit activity setup was successfully created." }
        format.json { render :show, status: :created, location: @permit_activity_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_activity_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_activity_setups/1 or /permit_activity_setups/1.json
  def update
    respond_to do |format|
      if @permit_activity_setup.update(permit_activity_setup_params)
        format.html { redirect_to @permit_activity_setup, notice: "Permit activity setup was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_activity_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_activity_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_activity_setups/1 or /permit_activity_setups/1.json
  def destroy
    @permit_activity_setup.destroy
    respond_to do |format|
      format.html { redirect_to permit_activity_setups_url, notice: "Permit activity setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_activity_setup
      @permit_activity_setup = PermitActivitySetup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_activity_setup_params
      params.require(:permit_activity_setup).permit(:permit_type_id, :name, :site_id ,:parent_id)
    end
end
