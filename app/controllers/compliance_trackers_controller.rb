class ComplianceTrackersController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_compliance_tracker, only: %i[ show edit update destroy ]

  # GET /compliance_trackers or /compliance_trackers.json
  def index
    @compliance_trackers = ComplianceTracker.where(site_id: @user.current_site_id).ransack(params[:q]).result.distinct
  end

  # GET /compliance_trackers/1 or /compliance_trackers/1.json
  def show
  end

  # GET /compliance_trackers/new
  def new
    @compliance_tracker = ComplianceTracker.new
  end

  # GET /compliance_trackers/1/edit
  def edit
  end

  # POST /compliance_trackers or /compliance_trackers.json
  def create
    @compliance_tracker = ComplianceTracker.new(compliance_tracker_params)

    respond_to do |format|
      if @compliance_tracker.save
        format.html { redirect_to @compliance_tracker, notice: "Compliance tracker was successfully created." }
        format.json { render :show, status: :created, location: @compliance_tracker }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @compliance_tracker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compliance_trackers/1 or /compliance_trackers/1.json
  def update
    respond_to do |format|
      if @compliance_tracker.update(compliance_tracker_params)
        format.html { redirect_to @compliance_tracker, notice: "Compliance tracker was successfully updated." }
        format.json { render :show, status: :ok, location: @compliance_tracker }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compliance_tracker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compliance_trackers/1 or /compliance_trackers/1.json
  def destroy
    @compliance_tracker.destroy
    respond_to do |format|
      format.html { redirect_to compliance_trackers_url, notice: "Compliance tracker was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compliance_tracker
      @compliance_tracker = ComplianceTracker.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def compliance_tracker_params
      params.require(:compliance_tracker).permit(:compliance_config_id, :status, :submitted_on, :submitted_by_id, :site_id,:due_date)
    end
end
