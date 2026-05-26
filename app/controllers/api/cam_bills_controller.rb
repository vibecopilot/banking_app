module Api
  class CamBillsController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      scope = CamUnitBill.all
      if params[:year].present?
        scope = scope.where(year: params[:year].to_i)
      end
      if params[:month].present?
        scope = scope.where(month: params[:month].to_i)
      end
      render json: { data: scope.order(:unit_id) }
    end

    def preview
      settings = fetch_settings!
      ucs = CamUnitConfig.all
      smp = fetch_society_maintenance_percent
      calc = CamBillCalculator.new(settings: settings, unit_configs: ucs, year: params[:year], month: params[:month], society_maintenance_percent: smp)
      data = calc.call
      render json: { data: data }
    end

    def generate
      settings = fetch_settings!
      ucs = CamUnitConfig.all
      smp = fetch_society_maintenance_percent
      calc = CamBillCalculator.new(settings: settings, unit_configs: ucs, year: params[:year], month: params[:month], society_maintenance_percent: smp)
      data = calc.call
      data.each do |row|
        bill = CamUnitBill.find_or_initialize_by(unit_id: row[:unit_id], year: row[:year], month: row[:month])
        permitted_attrs = row.slice(
          :unit_id,
          :year,
          :month,
          :carpet_area_sqft,
          :daily_rate_per_sqft,
          :active_days,
          :base_amount,
          :gst_rate_percent,
          :gst_amount,
          :total_amount
        )
        bill.assign_attributes(permitted_attrs.merge(status: bill.status.presence || 'generated', site_id: params[:site_id]))
        bill.save!
      end
      render json: { data: CamUnitBill.where(year: params[:year], month: params[:month]) }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def fetch_settings!
      setting = params[:project_id].present? ? CamSetting.find_by(project_id: params[:project_id]) : CamSetting.first
      raise ActiveRecord::RecordNotFound, 'CAM settings not found' unless setting
      setting
    end

    def fetch_society_maintenance_percent
      site = nil
      site = Site.find_by(id: params[:site_id]) if params[:site_id].present?
      site ||= Site.find_by(id: params[:project_id]) if params[:project_id].present?
      bc = site&.billing_configuration
      bc&.management_fee_percentage.to_f
    end
  end
end
