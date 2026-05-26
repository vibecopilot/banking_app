class Api::Accounting::CamController < ApplicationController
  protect_from_forgery with: :null_session

  def generate
    period = params[:period]
    return render json: { error: 'period is required (YYYY-MM)' }, status: :unprocessable_entity unless period.present?
    year, month = period.split('-').map(&:to_i)

    settings = CamSetting.first
    return render json: { error: 'CAM settings not found' }, status: :not_found unless settings
    ucs = CamUnitConfig.all
    calc = CamBillCalculator.new(settings: settings, unit_configs: ucs, year: year, month: month)
    data = calc.call

    data.each do |row|
      bill = CamUnitBill.find_or_initialize_by(unit_id: row[:unit_id], year: row[:year], month: row[:month])
      bill.assign_attributes(row.merge(status: bill.status.presence || 'generated'))
      bill.save!
    end

    render json: { data: CamUnitBill.where(year: year, month: month) }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def summary
    period = params[:period]
    return render json: { error: 'period is required (YYYY-MM)' }, status: :unprocessable_entity unless period.present?
    year, month = period.split('-').map(&:to_i)

    bills = CamUnitBill.where(year: year, month: month)
    total_subtotal = bills.sum(:base_amount)
    total_gst = bills.sum(:gst_amount)
    total = bills.sum(:total_amount)

    per_unit = bills.order(:unit_id).map do |b|
      {
        unit_id: b.unit_id,
        year: b.year,
        month: b.month,
        subtotal: b.base_amount,
        gst_percent: b.gst_rate_percent,
        gst_amount: b.gst_amount,
        total: b.total_amount,
        status: b.status
      }
    end

    render json: { data: { totals: { subtotal: total_subtotal, gst_amount: total_gst, total: total }, units: per_unit } }
  end
end
