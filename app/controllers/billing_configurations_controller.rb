class BillingConfigurationsController < ApplicationController
  before_action :api_user
  before_action :set_site
  before_action :validate_site
  before_action :set_billing_configuration, only: [:show, :update, :destroy, :upload_logo]
  skip_before_action :verify_authenticity_token, only: [:upload_logo]

  # GET /billing_configurations.json
  def index
    @billing_configuration = @site.billing_configuration
    render json: @billing_configuration || {}
  end

  # GET /billing_configurations/:id.json
  def show
    render json: @billing_configuration
  end

  # POST /billing_configurations.json
  def create
    @billing_configuration = @site.build_billing_configuration(billing_configuration_params)
    
    if @billing_configuration.save
      render json: {
        success: true,
        message: "Billing configuration created successfully",
        billing_configuration: @billing_configuration
      }, status: :created
    else
      render json: {
        success: false,
        message: "Failed to create billing configuration",
        errors: @billing_configuration.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /billing_configurations/:id.json
  def update
    if @billing_configuration.update(billing_configuration_params)
      render json: {
        success: true,
        message: "Billing configuration updated successfully",
        billing_configuration: @billing_configuration
      }
    else
      render json: {
        success: false,
        message: "Failed to update billing configuration",
        errors: @billing_configuration.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /billing_configurations/:id.json
  def destroy
    @billing_configuration.destroy
    render json: {
      success: true,
      message: "Billing configuration deleted successfully"
    }
  end

  # POST /billing_configurations/:id/upload_logo
  def upload_logo
    unless params[:logo].present?
      render json: {
        success: false,
        message: "No logo file provided"
      }, status: :unprocessable_entity and return
    end

    attachfile = @billing_configuration.logo || Attachfile.new
    attachfile.relation = "BillingConfiguration"
    attachfile.relation_id = @billing_configuration.id
    attachfile.image = params[:logo]
    attachfile.active = true

    if attachfile.save
      # Use whole_path to generate a full URL if needed
      logo_url = attachfile.whole_path(request.host)

      @billing_configuration.update(company_logo: logo_url)

      render json: {
        success: true,
        message: "Logo uploaded successfully",
        logo_url: logo_url,
        billing_configuration: @billing_configuration
      }
    else
      render json: {
        success: false,
        message: "Failed to upload logo",
        errors: attachfile.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_site
    @site = @user&.site
    @site ||= Site.find(params[:site_id]) if params[:site_id].present?
    @site ||= Site.find_by(id: request.headers['Site-Id']) if request.headers['Site-Id'].present?
  end

  def validate_site
    unless @site
      render json: {
        success: false,
        message: "Site not found. Please provide site_id parameter or ensure user is authenticated."
      }, status: :unprocessable_entity
    end
  end

  def set_billing_configuration
    @billing_configuration = @site.billing_configuration
    unless @billing_configuration
      render json: {
        success: false,
        message: "Billing configuration not found for this site"
      }, status: :not_found
    end
  end

  def billing_configuration_params
    params.require(:billing_configuration).permit(
      :company_name,
      :company_logo,
      :gst_number,
      :pan_number,
      :address,
      :city,
      :state,
      :pincode,
      :phone,
      :email,
      :website,
      :bank_name,
      :account_number,
      :ifsc_code,
      :branch_name,
      :favouring_name,
      :account_type,
      :swift_code,
      :terms_and_conditions,
      :enable_gst_split,
      :enable_igst,
      :society_maintenance_percent,
      :management_fees_label,
      :management_fees_enabled
    )
  end
end
