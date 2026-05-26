class Api::Accounting::TenantFeesController < ApplicationController
  protect_from_forgery with: :null_session

  def invoice
    attrs = params.permit(:unit_id, :type, :base_fee, :gst_percent, :effective_on)
    setting = CamSetting.first
    return render json: { error: 'CAM settings not found' }, status: :not_found unless setting

    base = (attrs[:base_fee].presence || default_base_fee(setting, attrs[:type])).to_d
    gst_rate = (attrs[:gst_percent].presence || default_gst(setting, attrs[:type])).to_d
    gst = (base * gst_rate / 100).round(2)
    total = (base + gst).round(2)

    tc = CamTenantCharge.create!(
      unit_id: attrs[:unit_id],
      charge_type: attrs[:type] == 'move_out' ? 'move_out' : 'move_in',
      base_amount: base,
      gst_rate_percent: gst_rate,
      gst_amount: gst,
      total_amount: total,
      date: attrs[:effective_on] || Date.current,
      status: 'pending'
    )

    render json: { data: { invoice_id: tc.id, subtotal: base, gst_amount: gst, total: total } }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def config
    setting = CamSetting.first
    return render json: { error: 'CAM settings not found' }, status: :not_found unless setting
    render json: { data: {
      tenant_move_in_fee: setting.try(:tenant_move_in_fee),
      tenant_move_out_fee: setting.try(:tenant_move_out_fee),
      gst_rate_move_in: setting.try(:gst_rate_move_in),
      gst_rate_move_out: setting.try(:gst_rate_move_out)
    } }
  end

  private

  def default_base_fee(setting, type)
    type == 'move_out' ? (setting.try(:tenant_move_out_fee).to_d) : (setting.try(:tenant_move_in_fee).to_d)
  end

  def default_gst(setting, type)
    type == 'move_out' ? (setting.try(:gst_rate_move_out).to_d) : (setting.try(:gst_rate_move_in).to_d)
  end
end
