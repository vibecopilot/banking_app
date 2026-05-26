module Api
  class CamSettingsController < ApplicationController
    protect_from_forgery with: :null_session

    def show
      setting = find_setting
      render json: { data: setting }
    end

    def create
      setting = find_setting || CamSetting.new
      attrs = setting_payload
      if setting.update(attrs)
        render json: { data: setting }, status: :ok
      else
        render json: { error: setting.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def find_setting
      if params[:project_id].present?
        CamSetting.find_by(project_id: params[:project_id])
      else
        CamSetting.first
      end
    end

    def setting_payload
      # Accept both { setting: { .. } } and { cam_setting: { .. } } and { setting: { cam_setting: { .. } } }
      payload = params[:setting]
      payload = payload[:cam_setting] if payload.is_a?(ActionController::Parameters) && payload.key?(:cam_setting)
      payload ||= params[:cam_setting]

      payload = ActionController::Parameters.new if payload.blank?

      # Permit only columns that exist to avoid unknown-attribute errors
      candidate_keys = [
        :project_id,
        :rate_per_sqft,
        :gst_rate_percent,
        :advance_months_required,
        :gst_rate_move_in,
        :gst_rate_move_out
      ]
      existing_columns = CamSetting.column_names.map(&:to_sym)
      permitted_keys = candidate_keys & existing_columns
      payload.permit(*permitted_keys)
    end
  end
end
