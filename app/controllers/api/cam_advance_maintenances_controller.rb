module Api
  class CamAdvanceMaintenancesController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      scope = CamAdvanceMaintenance.all
      scope = scope.where(unit_id: params[:unit_id]) if params[:unit_id].present?
      render json: { data: scope.order(:demand_no) }
    end

    def generate
      unit_id = params.require(:unit_id)
      months = (params[:months] || default_months_required).to_i
      start_date = Date.parse(params[:start_date].to_s)

      setting = fetch_settings!
      uc = CamUnitConfig.find_by(unit_id: unit_id)
      return render json: { error: 'Unit config not found' }, status: :not_found unless uc

      monthly_base = (setting.rate_per_sqft.to_d * uc.carpet_area_sqft.to_d).round(2)
      gst_rate = setting.gst_rate_percent.to_d

      created = []
      (1..months).each do |i|
        due = start_date.advance(months: i - 1)
        base = monthly_base
        gst = (base * gst_rate / 100).round(2)
        total = (base + gst).round(2)

        am = CamAdvanceMaintenance.create!(
          unit_id: unit_id,
          demand_no: i,
          due_date: due,
          base_amount: base,
          gst_rate_percent: gst_rate,
          gst_amount: gst,
          total_amount: total,
          status: 'pending'
        )
        created << am
      end

      render json: { data: created }
    rescue ArgumentError
      render json: { error: 'Invalid start_date' }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def default_months_required
      CamSetting.first&.advance_months_required || 0
    end

    def fetch_settings!
      CamSetting.first || (raise ActiveRecord::RecordNotFound, 'CAM settings not found')
    end
  end
end
