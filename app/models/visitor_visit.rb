class VisitorVisit < ApplicationRecord
  belongs_to :visitor
  
  after_create :notify_on_checkin_create, if: :should_notify_on_create?
  after_update :notify_on_checkin_checkout, if: :should_notify_on_update?

  private

  def should_notify_on_create?
    check_in.present?
  end

  def should_notify_on_update?
    check_out.present?
  end

  def notify_on_checkin_create
    Rails.logger.info("VisitorVisit created with check_in for visitor #{visitor_id}")
    VisitorCheckinCheckoutNotificationJob.perform_later(visitor_id, 'check_in')
  end

  def notify_on_checkin_checkout
    Rails.logger.info("VisitorVisit check_out updated for visitor #{visitor_id}")
    VisitorCheckinCheckoutNotificationJob.perform_later(visitor_id, 'check_out')
  end
end