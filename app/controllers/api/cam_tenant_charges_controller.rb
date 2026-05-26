module Api
  class CamTenantChargesController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      scope = CamTenantCharge.all
      scope = scope.where(unit_id: params[:unit_id]) if params[:unit_id].present?
      if params[:from].present? && params[:to].present?
        from = Date.parse(params[:from])
        to = Date.parse(params[:to])
        scope = scope.where(date: from..to)
      end
      render json: { data: scope.order(date: :desc) }
    rescue ArgumentError
      render json: { error: 'Invalid from/to date' }, status: :unprocessable_entity
    end

    def create
      setting = CamSetting.first
      return render json: { error: 'CAM settings not found' }, status: :not_found unless setting

      attrs = tenant_charge_params.to_h.symbolize_keys
      base = attrs[:base_amount].to_d
      gst_rate = (attrs[:gst_rate_percent] || setting.gst_rate_percent).to_d
      gst = (base * gst_rate / 100).round(2)
      total = (base + gst).round(2)

      tc = CamTenantCharge.new(attrs.merge(gst_rate_percent: gst_rate, gst_amount: gst, total_amount: total))
      if tc.save
        render json: { data: tc }, status: :created
      else
        render json: { error: tc.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def tenant_charge_params
      params.require(:tenant_charge).permit(:unit_id, :charge_type, :base_amount, :gst_rate_percent, :date, :status)
    end
  end
end
