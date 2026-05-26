class Api::Accounting::AdvancePaymentsController < ApplicationController
  protect_from_forgery with: :null_session

  def record
    attrs = params.permit(:unit_id, :months_paid, :amount, :paid_on, :possession_date_ref, :mode, :reference_no)
    entry = AdvancePaymentLedger.create!(attrs)
    render json: { data: entry }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def status
    unit_id = params[:unit_id]
    return render json: { error: 'unit_id is required' }, status: :unprocessable_entity unless unit_id.present?

    required_months = CamSetting.first&.advance_months_required.to_i
    months_paid_total = AdvancePaymentLedger.where(unit_id: unit_id).sum(:months_paid).to_i
    outstanding_months = [required_months - months_paid_total, 0].max
    is_clear_for_possession = outstanding_months.zero?

    render json: { data: { required_months: required_months, months_paid_total: months_paid_total, is_clear_for_possession: is_clear_for_possession, outstanding_months: outstanding_months } }
  end
end
