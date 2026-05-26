class FieldSenseLeadsManagementsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_field_sense_leads_management, only: %i[ show edit update destroy ]

  # GET /field_sense_leads_managements or /field_sense_leads_managements.json
  def index
    @field_sense_leads_managements = FieldSenseLeadsManagement.all
  end

  # GET /field_sense_leads_managements/1 or /field_sense_leads_managements/1.json
  def show
  end

  # GET /field_sense_leads_managements/new
  def new
    @field_sense_leads_management = FieldSenseLeadsManagement.new
  end

  # GET /field_sense_leads_managements/1/edit
  def edit
  end

  # POST /field_sense_leads_managements or /field_sense_leads_managements.json
  def create
    @field_sense_leads_management = FieldSenseLeadsManagement.new(field_sense_leads_management_params)

    respond_to do |format|
      if @field_sense_leads_management.save
        format.html { redirect_to @field_sense_leads_management, notice: "Field sense leads management was successfully created." }
        format.json { render :show, status: :created, location: @field_sense_leads_management }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @field_sense_leads_management.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /field_sense_leads_managements/1 or /field_sense_leads_managements/1.json
  def update
    respond_to do |format|
      if @field_sense_leads_management.update(field_sense_leads_management_params)
        format.html { redirect_to @field_sense_leads_management, notice: "Field sense leads management was successfully updated." }
        format.json { render :show, status: :ok, location: @field_sense_leads_management }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @field_sense_leads_management.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /field_sense_leads_managements/1 or /field_sense_leads_managements/1.json
  def destroy
    @field_sense_leads_management.destroy
    respond_to do |format|
      format.html { redirect_to field_sense_leads_managements_url, notice: "Field sense leads management was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_field_sense_leads_management
      @field_sense_leads_management = FieldSenseLeadsManagement.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def field_sense_leads_management_params
      params.require(:field_sense_leads_management).permit(:lead_name, :lead_source, :contact_phone, :contact_email, :company_name, :lead_status, :assigned_sales_representative, :last_contact_date, :next_follow_up_date, :created_by_id)
    end
end
