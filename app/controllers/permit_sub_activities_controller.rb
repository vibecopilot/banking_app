class PermitSubActivitiesController < ApplicationController
   include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_permit_sub_activity, only: %i[ show edit update destroy ]

  # GET /permit_sub_activities or /permit_sub_activities.json
  def index
    @permit_sub_activities = PermitSubActivity.all
  end

  # GET /permit_sub_activities/1 or /permit_sub_activities/1.json
  def show
  end

  # GET /permit_sub_activities/new
  def new
    @permit_sub_activity = PermitSubActivity.new
  end

  # GET /permit_sub_activities/1/edit
  def edit
  end

  # POST /permit_sub_activities or /permit_sub_activities.json
  def create
    @permit_sub_activity = PermitSubActivity.new(permit_sub_activity_params)

    respond_to do |format|
      if @permit_sub_activity.save
        format.html { redirect_to @permit_sub_activity, notice: "Permit sub activity was successfully created." }
        format.json { render :show, status: :created, location: @permit_sub_activity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_sub_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_sub_activities/1 or /permit_sub_activities/1.json
  def update
    respond_to do |format|
      if @permit_sub_activity.update(permit_sub_activity_params)
        format.html { redirect_to @permit_sub_activity, notice: "Permit sub activity was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_sub_activity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_sub_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_sub_activities/1 or /permit_sub_activities/1.json
  def destroy
    @permit_sub_activity.destroy
    respond_to do |format|
      format.html { redirect_to permit_sub_activities_url, notice: "Permit sub activity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_sub_activity
      @permit_sub_activity = PermitSubActivity.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_sub_activity_params
      params.require(:permit_sub_activity).permit(:name, :permit_type_id, :permit_activity_setup_id)
    end
end
