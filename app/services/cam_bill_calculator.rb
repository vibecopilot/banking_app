class CamBillCalculator
  def initialize(settings:, unit_configs:, year:, month:, society_maintenance_percent: nil)
    @settings = settings
    @unit_configs = unit_configs
    @date = Date.new(year.to_i, month.to_i, 1)
    @society_maintenance_percent = society_maintenance_percent.present? ? society_maintenance_percent.to_d : BigDecimal("0")
  end

  def call
    period_start = @date.beginning_of_month
    period_end = @date.end_of_month
    dim = period_end.day

    @unit_configs
      .select { |u| u.cam_start_date && u.cam_start_date <= period_end }
      .map do |u|
        active_start = [u.cam_start_date, period_start].max
        active_days = (period_end - active_start + 1).to_i
        daily_rate_total = (@settings.rate_per_sqft.to_d * u.carpet_area_sqft.to_d) / dim
        base = daily_rate_total * active_days
        society_charge = base * (@society_maintenance_percent / 100)
        total = base + society_charge

        advance_amount = u.advance_amount.to_d
        advance_deduction = BigDecimal("0")
        if advance_amount.positive? && @date.year == u.cam_start_date.year && @date.month == u.cam_start_date.month
          advance_deduction = [advance_amount, total].min
          total -= advance_deduction
        end

        {
          unit_id: u.unit_id,
          year: @date.year,
          month: @date.month,
          carpet_area_sqft: u.carpet_area_sqft.to_d,
          daily_rate_per_sqft: (@settings.rate_per_sqft.to_d / dim),
          active_days: active_days,
          base_amount: base.round(2),
          gst_rate_percent: @society_maintenance_percent,
          gst_amount: society_charge.round(2),
          advance_amount: advance_amount.round(2),
          advance_deduction: advance_deduction.round(2),
          total_amount: total.round(2)
        }
      end
  end
end
