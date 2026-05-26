class CamBillCalculator
  def initialize(settings:, unit_configs:, year:, month:)
    @settings = settings
    @unit_configs = unit_configs
    @date = Date.new(year.to_i, month.to_i, 1)
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
        gst = base * (@settings.gst_rate_percent.to_d / 100)
        total = base + gst

        {
          unit_id: u.unit_id,
          year: @date.year,
          month: @date.month,
          carpet_area_sqft: u.carpet_area_sqft.to_d,
          daily_rate_per_sqft: (@settings.rate_per_sqft.to_d / dim),
          active_days: active_days,
          base_amount: base.round(2),
          gst_rate_percent: @settings.gst_rate_percent.to_d,
          gst_amount: gst.round(2),
          total_amount: total.round(2)
        }
      end
  end
end
