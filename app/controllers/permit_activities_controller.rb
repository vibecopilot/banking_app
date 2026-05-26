class PermitActivitiesController < ApplicationController
   include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_permit_activity, only: %i[ show edit update destroy ]

  # GET /permit_activities or /permit_activities.json
  def index
    @permit_activities = PermitActivity.all
  end

  # GET /permit_activities/1 or /permit_activities/1.json
  def show
  end

  # GET /permit_activities/new
  def new
    @permit_activity = PermitActivity.new
  end

  # GET /permit_activities/1/edit
  def edit
  end

  # POST /permit_activities or /permit_activities.json
  def create
    @permit_activity = PermitActivity.new(permit_activity_params)

    respond_to do |format|
      if @permit_activity.save
        format.html { redirect_to @permit_activity, notice: "Permit activity was successfully created." }
        format.json { render :show, status: :created, location: @permit_activity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_activities/1 or /permit_activities/1.json
  def update
    respond_to do |format|
      if @permit_activity.update(permit_activity_params)
        format.html { redirect_to @permit_activity, notice: "Permit activity was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_activity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_activities/1 or /permit_activities/1.json
  def destroy
    @permit_activity.destroy
    respond_to do |format|
      format.html { redirect_to permit_activities_url, notice: "Permit activity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_activity
      @permit_activity = PermitActivity.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_activity_params
      params.require(:permit_activity).permit(:permit_id, :activity, :sub_activity, :category_of_hazards, :risks)
    end
end
