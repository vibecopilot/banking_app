class PermitsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_permit, only: %i[ show edit update destroy ]

  # GET /permits or /permits.json
def index
  @q = Permit.ransack(params[:q])
  base_scope = @q.result.where(site_id: @user.current_site_id)
  @permits = base_scope.page(params[:page]).per(params[:per_page] || 20)
end


  # GET /permits/1 or /permits/1.json
  def show
  end

  # GET /permits/new
  def new
    @permit = Permit.new
  end

  # GET /permits/1/edit
  def edit
  end

  # POST /permits or /permits.json
  def create
    @permit = Permit.new(permit_params)

    respond_to do |format|
      if @permit.save
        if params[:permit][:permit_activities].present?
          params[:permit][:permit_activities].each do |activity|
            @permit_activity = PermitActivity.new(activity.permit(:permit_id, :activity, :sub_activity, :category_of_hazards, :risks))
            @permit_activity.permit_id = @permit.id
            @permit_activity.save
          end
        end
        format.html { redirect_to @permit, notice: "Permit was successfully created." }
        format.json { render :show, status: :created, location: @permit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permits/1 or /permits/1.json
  def update
    respond_to do |format|
      if @permit.update(permit_params)
        format.html { redirect_to @permit, notice: "Permit was successfully updated." }
        format.json { render :show, status: :ok, location: @permit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permits/1 or /permits/1.json
  def destroy
    @permit.destroy
    respond_to do |format|
      format.html { redirect_to permits_url, notice: "Permit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit
      @permit = Permit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_params
      params.require(:permit).permit(:name, :contact_number, :site_id, :unit_id, :permit_for, :building_id, :floor_id, :room_id, :client_specific, :entity, :copy_to_string, :permit_type, :vendor_id, :issue_date_and_time, :expiry_date_and_time, :comment, :permit_status, :extention_status, :created_by_id)
    end
end
