module Api
  class CamUnitConfigsController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      scope = CamUnitConfig.order(:unit_id)
      if params[:site_id].present?
        scope = scope.joins("INNER JOIN units ON units.id = unit_cam_configs.unit_id")
                     .where("units.site_id = ?", params[:site_id])
      end
      render json: { data: scope }
    end

    def create
      uc = CamUnitConfig.new(unit_config_params)
      if uc.save
        render json: { data: uc }, status: :created
      else
        render json: { error: uc.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      uc = CamUnitConfig.find(params[:id])
      if uc.update(unit_config_params)
        render json: { data: uc }, status: :ok
      else
        render json: { error: uc.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def unit_config_params
      params.require(:unit_config).permit(:unit_id, :carpet_area_sqft, :cam_start_date, :advance_amount)
    end
  end
end
