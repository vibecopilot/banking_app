module Api
  class CalculationsController < ApplicationController
    protect_from_forgery with: :null_session
#   skip_before_action :verify_authenticity_token, only: [:calculate_interest]


    # Calculate interest on overdue amount
    # POST /api/accounting/calculate-interest
    # Params:
    #   - principal: amount on which interest is calculated
    #   - rate: interest rate per annum (%)
    #   - days: number of days overdue
    #   - grace_period_days: number of grace days before interest starts (optional, default 0)
    #   - calculation_method: 'daily' (365), 'monthly' (30), 'simple', 'compound' (default: 'daily')
    def calculate_interest
      principal = params[:principal].to_f
      rate = params[:rate].to_f
      days = params[:days].to_i
      grace_period = params[:grace_period_days].to_i || 0
      method = params[:calculation_method] || 'daily'

      # Calculate days overdue after grace period
      days_after_grace = [days - grace_period, 0].max

      interest = if days_after_grace <= 0
                   0.0
                 elsif method == 'monthly'
                   # Monthly calculation (30 days per month)
                   (principal * rate * days_after_grace) / (12 * 100)
                 elsif method == 'compound'
                   # Compound interest
                   monthly_rate = rate / (12 * 100)
                   months = days_after_grace / 30.0
                   (principal * ((1 + monthly_rate) ** months - 1))
                 else
                   # Daily calculation (365 days per year) - default
                   (principal * rate * days_after_grace) / (365 * 100)
                 end

      total_payable = principal + interest

      render json: {
        principal: principal,
        rate: rate,
        days: days,
        grace_period_days: grace_period,
        days_after_grace: days_after_grace,
        calculation_method: method,
        interest: interest.round(2),
        total_payable: total_payable.round(2)
      }
    end

    # Calculate total income from income entries
    # POST /api/accounting/calculate-income-total
    # Params:
    #   - from_date: start date (optional)
    #   - to_date: end date (optional)
    #   - status: filter by status (optional)
    #   - source_type: filter by source type (optional)
    #   - site_id: site ID (optional)
    def calculate_income_total
      scope = IncomeEntry.all

      # Filter by income_month/income_year (period-based) or fallback to date range
      if params[:income_year].present? && params[:income_month].present?
        scope = scope.by_income_period(params[:income_year].to_i, params[:income_month].to_i)
      elsif params[:from_date].present? && params[:to_date].present?
        scope = scope.by_income_date_range(Date.parse(params[:from_date]), Date.parse(params[:to_date]))
      elsif params[:from_date].present?
        scope = scope.where('received_date >= ?', params[:from_date])
      elsif params[:to_date].present?
        scope = scope.where('received_date <= ?', params[:to_date])
      end

      # Filter by status
      scope = scope.where(status: params[:status]) if params[:status].present?

      # Filter by source_type
      scope = scope.where(source_type: params[:source_type]) if params[:source_type].present?

      # Filter by site
      scope = scope.where(site_id: params[:site_id]) if params[:site_id].present?

      total = scope.sum(:amount)
      count = scope.count

      # Calculate breakdown by status if requested
      breakdown = if params[:include_breakdown] == 'true'
                    {
                      by_status: scope.group(:status).sum(:amount).transform_keys(&:to_s).transform_values { |v| v.round(2) },
                      by_source: scope.group(:source_type).sum(:amount).transform_keys(&:to_s).transform_values { |v| v.round(2) }
                    }
                  else
                    {}
                  end

      render json: {
        total: total.to_f.round(2),
        count: count,
        from_date: params[:from_date],
        to_date: params[:to_date],
        status_filter: params[:status],
        source_filter: params[:source_type],
        breakdown: breakdown
      }
    end
  end
end
