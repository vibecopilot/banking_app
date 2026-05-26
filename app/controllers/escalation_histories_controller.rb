class EscalationHistoriesController < ApplicationController
  include UserExt
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user

  def index
    site_id = @user.current_site_id
    complaint_ids = Complaint.where(site_id: site_id).pluck(:id)
    @histories = EscHistory.where(complaint_id: complaint_ids)
                           .includes(:escalation_matrix)
                           .order(created_at: :desc)
                           .limit(100)
    render json: @histories.map { |h| esc_history_json(h) }
  end

  def update
    @history = EscHistory.find(params[:id])
    if params[:status].present?
      update_attrs = { status: params[:status] }
      update_attrs[:resolved_at] = Time.current if params[:status] == "resolved"
      @history.update!(update_attrs)
    end
    render json: esc_history_json(@history)
  end

  private

  def esc_history_json(h)
    level_name = h.escalation_matrix&.name
    level_num = level_name.to_s.gsub(/\D/, '').presence&.to_i || 1
    {
      id: h.id,
      ticketId: "INC-#{h.complaint_id.to_s.rjust(4, '0')}",
      level: [[level_num, 1].max, 4].min,
      triggeredAt: h.created_at,
      recipient: Array(h.esc_to).join(", "),
      reason: h.escalation_matrix&.complaint_worker&.esc_type || "SLA breach",
      status: h.status || "open",
    }
  end
end
