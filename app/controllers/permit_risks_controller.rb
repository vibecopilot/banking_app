class PermitRisksController < ApplicationController
   include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_permit_risk, only: %i[ show edit update destroy ]

  # GET /permit_risks or /permit_risks.json
  def index
    @permit_risks = PermitRisk.all
  end

  # GET /permit_risks/1 or /permit_risks/1.json
  def show
  end

  # GET /permit_risks/new
  def new
    @permit_risk = PermitRisk.new
  end

  # GET /permit_risks/1/edit
  def edit
  end

  # POST /permit_risks or /permit_risks.json
  def create
    @permit_risk = PermitRisk.new(permit_risk_params)

    respond_to do |format|
      if @permit_risk.save
        format.html { redirect_to @permit_risk, notice: "Permit risk was successfully created." }
        format.json { render :show, status: :created, location: @permit_risk }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_risk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_risks/1 or /permit_risks/1.json
  def update
    respond_to do |format|
      if @permit_risk.update(permit_risk_params)
        format.html { redirect_to @permit_risk, notice: "Permit risk was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_risk }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_risk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_risks/1 or /permit_risks/1.json
  def destroy
    @permit_risk.destroy
    respond_to do |format|
      format.html { redirect_to permit_risks_url, notice: "Permit risk was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_risk
      @permit_risk = PermitRisk.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_risk_params
      params.require(:permit_risk).permit(:permit_type_id, :activity_id, :sub_activity_id, :hazard_category_id, :risk_description, :risk_name)
    end
end
