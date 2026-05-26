class VisitorAlertConfigsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_config, only: [:show, :update]

  # GET /visitor_alert_config
  def show
    if @config
      render json: {
        enabled: @config.enabled,
        value: @config.threshold_value,
        unit: @config.threshold_unit
      }, status: :ok
    else
      # Return default values if no config exists
      render json: {
        enabled: false,
        value: 4,
        unit: 'hours'
      }, status: :ok
    end
  end

  # POST /visitor_alert_config or PUT /visitor_alert_config
  def update
    config_params = {
      enabled: params[:enabled],
      threshold_value: params[:value],
      threshold_unit: params[:unit],
      site_id: @user.current_site_id
    }

    if @config
      if @config.update(config_params)
        render json: {
          message: 'Visitor alert settings updated successfully',
          config: {
            enabled: @config.enabled,
            value: @config.threshold_value,
            unit: @config.threshold_unit
          }
        }, status: :ok
      else
        render json: { errors: @config.errors.full_messages }, status: :unprocessable_entity
      end
    else
      @config = VisitorAlertConfig.new(config_params)
      if @config.save
        render json: {
          message: 'Visitor alert settings created successfully',
          config: {
            enabled: @config.enabled,
            value: @config.threshold_value,
            unit: @config.threshold_unit
          }
        }, status: :created
      else
        render json: { errors: @config.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def set_config
    @config = VisitorAlertConfig.find_by(site_id: @user.current_site_id)
  end
end
