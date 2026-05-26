class ComplianceConfigsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_compliance_config, only: %i[ show edit update destroy ]

  # GET /compliance_configs or /compliance_configs.json
  def index
    @compliance_configs = ComplianceConfig.where(site_id: @user.current_site_id).ransack(params[:q]).result
  end

  # GET /compliance_configs/1 or /compliance_configs/1.json
  def show
  end

  # GET /compliance_configs/new
  def new
    @compliance_config = ComplianceConfig.new
  end

  # GET /compliance_configs/1/edit
  def edit
  end

  # POST /compliance_configs or /compliance_configs.json
  def create
    @compliance_config = ComplianceConfig.new(compliance_config_params)
    respond_to do |format|
      if @compliance_config.save
        if params[:attachments].present?
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "ComplianceConfig", relation_id: @compliance_config.id, active: 1)
          end
        end
        format.html { redirect_to @compliance_config, notice: "Compliance config was successfully created." }
        format.json { render :show, status: :created, location: @compliance_config }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @compliance_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compliance_configs/1 or /compliance_configs/1.json
  def update
    respond_to do |format|
      if @compliance_config.update(compliance_config_params)
        format.html { redirect_to @compliance_config, notice: "Compliance config was successfully updated." }
        format.json { render :show, status: :ok, location: @compliance_config }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compliance_config.errors, status: :unprocessable_entity }
      end
    end
  end

def generate_certificate
  @certificate = ComplianceConfig.find(params[:id])

  render pdf: "Certificate_#{@certificate.cert_number}",
         template: "compliance_configs/g_certificate.html",
         layout: "pdf_layout",
         disposition: "attachment",
         page_size: "A4",
         orientation: "Landscape",
         margin: { top: 0, bottom: 0, left: 0, right: 0 },
         dpi: 300,
         encoding: "UTF-8"
end

  # DELETE /compliance_configs/1 or /compliance_configs/1.json
  def destroy
    @compliance_config.destroy
    respond_to do |format|
      format.html { redirect_to compliance_configs_url, notice: "Compliance config was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_compliance_config
    @compliance_config = ComplianceConfig.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def compliance_config_params
    params.require(:compliance_config).permit(:name, :cert_number, :frequency, :due_in_days, :priority, :description, :assign_to_id, :reviewer_id, :start_date, :end_date, :site_id)
  end
end
