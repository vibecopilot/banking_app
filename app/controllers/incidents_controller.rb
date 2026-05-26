class IncidentsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_incident, only: %i[ show edit update destroy ]

  # GET /incidents or /incidents.json
  def index
    @q = Incident.ransack(params[:q])
    base_scope = @q.result.joins(:user).where(users: {current_site_id: @user.selected_site_id}).includes(:attachments, :incident_injuries, :witnesses, :investigation_teams, :cost_of_incident, :user, :building)
    @incidents = base_scope.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 50)
  end

  # GET /incidents/1 or /incidents/1.json
  def show
    # incident = Incident.find(params[:id])
    # render json: incident.as_json(
    #   include: {
    #     attachments: { only: [:id, :file_file_name, :file_file_size] ,methods: [:file_url] },
    #     witnesses: { only: [:id, :name, :mobile] },
    #     investigation_teams: { only: [:id, :name, :mobile, :designation] },
    #     cost_of_incident: { only: [:equipment_property_cost, :production_loss, :treatment_cost, :absenteeism_cost, :other_cost, :total_cost] }
    #   }
    # )
  end

  # GET /incidents/new
  def new
    @incident = Incident.new
  end

  # GET /incidents/1/edit
  def edit
  end

  # POST /incidents or /incidents.json
  def create
    @incident = Incident.new(incident_params)
    respond_to do |format|
      if @incident.save
        format.html { redirect_to @incident, notice: "Incident was successfully created." }
        format.json { render :show, status: :created, location: @incident }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incidents/1 or /incidents/1.json
  def update
    respond_to do |format|
      if @incident.update(incident_params)
        format.html { redirect_to @incident, notice: "Incident was successfully updated." }
        format.json { render :show, status: :ok, location: @incident }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incidents/1 or /incidents/1.json
  def destroy
    @incident.destroy
    respond_to do |format|
      format.html { redirect_to incidents_url, notice: "Incident was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incident
      @incident = Incident.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def incident_params
      params.require(:incident).permit(
        :time_and_date, 
        :primary_incident_category, 
        :secondary_incident_category, 
        :primary_incident_sub_category, 
        :primary_incident_sub_sub_category, 
        :secondary_incident_sub_category, 
        :secondary_incident_sub_sub_category, 
        :property_damage, 
        :rca, 
        :primary_root_cause_category, 
        :corrective_action, 
        :preventive_action, 
        :first_aid_provided_employee, 
        :sent_medical_treatment, 
        :support_required, 
        :read_facts_states,
        :incident_severity,
        :incident_level,
        :building_id,
        :probability,
        :description,
        :created_by_id,
        :status,
        :insured_by,
        :read_fact_state,
        :first_aid_attendant,
        :treatment_facility,
        :attending_physician,
        :property_damage_category,
        :damage_coverd_under_insurance,
        attachments_attributes: [ :file, :_destroy],
        witnesses_attributes: [:id, :name, :mobile, :_destroy],
        investigation_teams_attributes: [:id, :name, :mobile, :designation, :_destroy],
        cost_of_incident_attributes: [:id, :equipment_property_cost, :production_loss, :treatment_cost, :absenteeism_cost, :other_cost, :total_cost, :_destroy]
      )
    end
end
