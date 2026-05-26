class CompaniesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_company, only: %i[ show edit update destroy ]

  # GET /companies or /companies.json
  def index
    @q = Company.ransack(params[:q])
    @companies = @q.result.includes(:organization, :created_by_user).order(created_at: :desc).page(params[:page]).per(params[:per_page] || 20)
    respond_to do |format|
      format.html
      format.json { render json: @companies }
    end
  end

  # GET /companies/1 or /companies/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params.merge(created_by: @user.id))

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: "Company was successfully created." }
        format.json { render json: @company, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: "Company was successfully updated." }
        format.json { render json: @company, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: "Company was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /companies/list - Get all companies list
  def list
    @companies = Company.includes(:organization).all
    render json: @companies
  end

  # GET /companies/by_organization - Get companies by organization
  def by_organization
    if params[:organization_id].present?
      @companies = Company.where(organization_id: params[:organization_id]).includes(:organization)
      render json: @companies
    else
      render json: { error: "Organization ID is required" }, status: :bad_request
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.require(:company).permit(
      :name,
      :organization_id,
      :logo,
      :logo_file_name,
      :logo_content_type,
      :logo_file_size,
      :logo_updated_at,
      :entity,
      :site,
      :country,
      :region,
      :state,
      :city,
      :zone,
      :white_label,
      :sub_domain,
      :billing_type,
      :billing_for,
      :billing_term,
      :rate_per_bill,
      :billing_cycle,
      :start_time,
      :end_time
    )
  end
end
