class ServicePricingsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_service_pricing, only: [:show, :edit, :update, :destroy]

  # GET /service_pricings
  # GET /service_pricings.json
  def index
    @service_pricings = ServicePricing.joins(:service_subcategory)
                                     .where(service_subcategories: { site_id: @user.current_site_id })
                                     .active
                                     .includes(:service_subcategory, :unit_configuration).order(created_at: :desc)

    @service_pricings = @service_pricings.where(service_subcategory_id: params[:subcategory_id]) if params[:subcategory_id].present?

    respond_to do |format|
      format.html
      format.json do
        formatted_pricings = @service_pricings.map do |pricing|
          {
            id: pricing.id,
            service_subcategory_id: pricing.service_subcategory_id,
            unit_configuration_id: pricing.unit_configuration_id,
            subcategory_name: pricing.service_subcategory.name,
            unit_configuration_name: pricing.unit_configuration.name,
            original_price: pricing.price || 0,
            discount_percentage: pricing.discount_percentage || 0,
            discount_amount: pricing.discount_amount || 0,
            tax_percentage: pricing.tax_percentage || 0,
            tax_amount: pricing.tax_amount || 0,
            final_price: pricing.final_price || pricing.price || 0,
            active: pricing.active,
            created_at: pricing.created_at,
            updated_at: pricing.updated_at
          }
        end
        
        render json: formatted_pricings
      end
    end
  end

  # GET /service_pricings/1
  # GET /service_pricings/1.json
  def show
    respond_to do |format|
      format.html
      format.json do
        render json: {
          id: @service_pricing.id,
          subcategory: {
            id: @service_pricing.service_subcategory.id,
            name: @service_pricing.service_subcategory.name
          },
          unit_configuration: {
            id: @service_pricing.unit_configuration.id,
            name: @service_pricing.unit_configuration.name
          },
          **@service_pricing.price_breakdown
        }
      end
    end
  end

  # GET /service_pricings/new
  def new
    @service_pricing = ServicePricing.new
    @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
    @unit_configurations = UnitConfiguration.for_site(@user.current_site_id).active.order(:name)
  end

  # GET /service_pricings/1/edit
  def edit
    @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
    @unit_configurations = UnitConfiguration.for_site(@user.current_site_id).active.order(:name)
  end

  # POST /service_pricings
  # POST /service_pricings.json
  def create
    @service_pricing = ServicePricing.new(service_pricing_params)
    
    respond_to do |format|
      if @service_pricing.save
        format.html { redirect_to @service_pricing, notice: 'Service pricing was successfully created.' }
        format.json { render json: @service_pricing, status: :created }
      else
        format.html do
          @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
          @unit_configurations = UnitConfiguration.for_site(@user.current_site_id).active.order(:name)
          render :new
        end
        format.json { render json: @service_pricing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_pricings/1
  # PATCH/PUT /service_pricings/1.json
  def update
    respond_to do |format|
      if @service_pricing.update(service_pricing_params)
        format.html { redirect_to @service_pricing, notice: 'Service pricing was successfully updated.' }
        format.json { render json: @service_pricing }
      else
        format.html do
          @service_subcategories = ServiceSubcategory.for_site(@user.current_site_id).active.ordered
          @unit_configurations = UnitConfiguration.for_site(@user.current_site_id).active.order(:name)
          render :edit
        end
        format.json { render json: @service_pricing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_pricings/1
  # DELETE /service_pricings/1.json
  def destroy
    @service_pricing.update(active: false)
    
    respond_to do |format|
      format.html { redirect_to service_pricings_url, notice: 'Service pricing was successfully deactivated.' }
      format.json { head :no_content }
    end
  end

  # POST /service_pricings/bulk_create
  def bulk_create
    subcategory_id = params[:service_subcategory_id]
    pricing_data = params[:pricing_data] || []

    unless subcategory_id.present? && pricing_data.any?
      return render json: { error: "Service subcategory and pricing data are required" }, status: :unprocessable_entity
    end

    # Validate that the service subcategory belongs to current site
    service_subcategory = ServiceSubcategory.find_by(id: subcategory_id)
    unless service_subcategory && service_subcategory.site_id == @user.current_site_id
      return render json: { error: "Service subcategory not found" }, status: :not_found
    end

    results = []
    errors = []

    pricing_data.each do |config|
      # Skip if price is blank or zero
      next if config[:price].blank? || config[:price].to_f <= 0

      pricing = ServicePricing.new(
        service_subcategory_id: subcategory_id,
        unit_configuration_id: config[:unit_configuration_id],
        price: config[:price].to_f,
        discount_percentage: config[:discount_percentage] || 0,
        tax_percentage: config[:tax_percentage] || 0,
        active: true
      )

      if pricing.save
        results << {
          id: pricing.id,
          unit_configuration_id: pricing.unit_configuration_id,
          unit_configuration_name: pricing.unit_configuration.name,
          **pricing.price_breakdown
        }
      else
        errors << { 
          unit_configuration_id: config[:unit_configuration_id], 
          errors: pricing.errors.full_messages 
        }
      end
    end

    respond_to do |format|
      if errors.empty?
        format.json { 
          render json: { 
            message: "#{results.count} pricing(s) created successfully", 
            pricings: results 
          }, status: :created 
        }
      else
        format.json { 
          render json: { 
            message: "Some pricings failed to create", 
            successes: results.count, 
            created_pricings: results,
            errors: errors 
          }, status: :partial_content
        }
      end
    end
  end

  private

  def set_service_pricing
    @service_pricing = ServicePricing.find(params[:id])
  end

  def service_pricing_params
    params.require(:service_pricing).permit(:price, :discount_percentage, :tax_percentage, :active, :service_subcategory_id, :unit_configuration_id)
  end
end
