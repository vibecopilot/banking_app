class ServiceCategoriesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_service_category, only: [:show, :edit, :update, :destroy]

  # GET /service_categories
  # GET /service_categories.json
  def index
    @service_categories = ServiceCategory.for_site(@user.current_site_id)
                                        .active
                                        .ordered
                                        .includes(:service_subcategories)
    respond_to do |format|
      format.html
      format.json do
        render json: @service_categories.map do |category|
          {
            id: category.id,
            name: category.name,
            description: category.description,
            icon_url: category.icon_url,
            sort_order: category.sort_order,
            subcategories_count: category.subcategories_count,
            created_at: category.created_at,
            updated_at: category.updated_at,
            active: category.active
          }
        end
      end
    end
  end

  # GET /service_categories/1
  # GET /service_categories/1.json
  def show
    @subcategories = @service_category.service_subcategories.active.ordered

    respond_to do |format|
      format.html
      format.json do
        render json: {
          id: @service_category.id,
          name: @service_category.name,
          description: @service_category.description,
          icon_url: @service_category.icon_url,
          subcategories: @subcategories.map do |sub|
            {
              id: sub.id,
              name: sub.name,
              description: sub.description,
              duration_minutes: sub.duration_minutes,
              advance_booking_hours: sub.advance_booking_hours
            }
          end
        }
      end
    end
  end

  # GET /service_categories/new
  def new
    @service_category = ServiceCategory.new
  end

  # GET /service_categories/1/edit
  def edit
  end

  # POST /service_categories
  # POST /service_categories.json
  def create
    @service_category = ServiceCategory.new(service_category_params)
    @service_category.site_id = @user.current_site_id

    respond_to do |format|
      if @service_category.save
        format.html { redirect_to @service_category, notice: 'Service category was successfully created.' }
        format.json { render json: @service_category, status: :created }
      else
        format.html { render :new }
        format.json { render json: @service_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_categories/1
  # PATCH/PUT /service_categories/1.json
  def update
    respond_to do |format|
      if @service_category.update(service_category_params)
        format.html { redirect_to @service_category, notice: 'Service category was successfully updated.' }
        format.json { render json: @service_category }
      else
        format.html { render :edit }
        format.json { render json: @service_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_categories/1
  # DELETE /service_categories/1.json
  def destroy
    @service_category.update(active: false)
    
    respond_to do |format|
      format.html { redirect_to service_categories_url, notice: 'Service category was successfully deactivated.' }
      format.json { head :no_content }
    end
  end

  private

  def set_service_category
    @service_category = ServiceCategory.find(params[:id])
  end

  def service_category_params
    params.require(:service_category).permit(:name, :description, :icon_url, :sort_order, :active)
  end
end
