class UnitConfigurationsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_unit_configuration, only: [:show, :edit, :update, :destroy]

  # GET /unit_configurations
  # GET /unit_configurations.json
  def index
    @unit_configurations = UnitConfiguration.for_site(@user.current_site_id)
                                            .active
                                            .order(:name)

    # Don't paginate for API calls unless specifically requested
    unless request.format.html?
      respond_to do |format|
        format.json do
          render json: @unit_configurations.map do |config|
            {
              id: config.id,
              name: config.name,
              description: config.description,
              bedrooms: config.bedrooms,
              bathrooms: config.bathrooms,
              halls: config.halls,
              kitchens: config.kitchens,
              carpet_area: config.carpet_area,
              built_up_area: config.built_up_area,
              display_name: config.display_name,
              area_info: config.area_info,
              active: config.active,
              created_at: config.created_at,
              updated_at: config.updated_at
            }
          end
        end
      end
      return
    end

    @unit_configurations = @unit_configurations.paginate(page: params[:page], per_page: params[:per_page] || 20)

    respond_to do |format|
      format.html
      format.json { render json: @unit_configurations }
    end
  end

  # GET /unit_configurations/1
  # GET /unit_configurations/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @unit_configuration }
    end
  end

  # GET /unit_configurations/new
  def new
    @unit_configuration = UnitConfiguration.new
  end

  # GET /unit_configurations/1/edit
  def edit
  end

  # POST /unit_configurations
  # POST /unit_configurations.json
  def create
    @unit_configuration = UnitConfiguration.new(unit_configuration_params)
    @unit_configuration.site_id = @user.current_site_id

    respond_to do |format|
      if @unit_configuration.save
        format.html { redirect_to @unit_configuration, notice: 'Unit configuration was successfully created.' }
        format.json { render json: @unit_configuration, status: :created }
      else
        format.html { render :new }
        format.json { render json: @unit_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unit_configurations/1
  # PATCH/PUT /unit_configurations/1.json
  def update
    respond_to do |format|
      if @unit_configuration.update(unit_configuration_params)
        format.html { redirect_to @unit_configuration, notice: 'Unit configuration was successfully updated.' }
        format.json { render json: @unit_configuration }
      else
        format.html { render :edit }
        format.json { render json: @unit_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_configurations/1
  # DELETE /unit_configurations/1.json
  def destroy
    @unit_configuration.update(active: false)

    respond_to do |format|
      format.html { redirect_to unit_configurations_url, notice: 'Unit configuration was successfully deactivated.' }
      format.json { head :no_content }
    end
  end

  private

  def set_unit_configuration
    @unit_configuration = UnitConfiguration.find(params[:id])
  end

  def unit_configuration_params
    params.require(:unit_configuration).permit(:name, :description, :bedrooms, :bathrooms, :halls, :kitchens, :carpet_area, :built_up_area, :active)
  end
end
