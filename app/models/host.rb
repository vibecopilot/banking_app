class Host < ApplicationRecord
  belongs_to :visitor
  belongs_to :user

  validates :visitor_id, presence: true
  validates :user_id, presence: true
  # Notification moved to VisitorNotificationJob for async processing
  # after_create :notify_assigned_to, if: -> { self.user_id.present? }
  after_update :notify_gatekeeper, if: -> { saved_change_to_is_approved? }

  #visitor_name, image, purpose
  def notify_assigned_to(type: "created")
    created_by = self.visitor.created_by
    ntype = created_by&.user_type == "security_guard" ? "Security_Visit" : "visitor"

    title = type == "reminder" ? "Visitor Reminder" : "Visitor Created"
    sendata = {
      title: title,
      profile_url: self.visitor.profile_pic&.whole_path,
      message: "New Visitor: #{self.visitor&.name} for purpose #{self.visitor&.purpose} is Created",
      v_name: self.visitor.try(:name),
      purpose: self.visitor&.purpose,
      ntype: ntype,
      user_id: user_id,
      company_id: self.visitor&.site&.company_id,
      record_id: self.visitor.id
    }
    puts sendata
    if self.visitor.skip_host_approval != true
      PushNotification.push_to_devices(UserDevice.where(user_id: self.user_id), sendata)
    end
  end

  def notify_gatekeeper
    # Avoid sending the same approval/rejection notification multiple times
    # when there are multiple hosts for the same visitor. Only the first
    # host that changes is_approved from nil -> value should notify.
    already_notified = Host.where(visitor_id: visitor_id)
    .where.not(id: id)
    .where.not(is_approved: nil)
    .exists?

    if already_notified
      Rails.logger.info "[VisitorNotify] Skipping gatekeeper notification for visitor=#{visitor_id}, host=#{id} (already notified)"
      return
    end

    # Use host approval flag (is_approved) to determine message, not visitor.status
    approval_text = is_approved? ? "Approved" : "Rejected"

    Rails.logger.info "[VisitorNotify] Gatekeeper notification for visitor=#{visitor_id}, host=#{id}, is_approved=#{is_approved.inspect}, visitor_status=#{visitor.status.inspect}"

    sendata = {
      title: "Visitor #{approval_text}",
      message: "Visitor:#{self.visitor&.name} for purpose #{self.visitor&.purpose} is #{approval_text}",
      ntype: "visitor",
      user_id: self.visitor.created_by_id,
      company_id: self.visitor&.site&.company_id,
      record_id: self.visitor.id
    }

    PushNotification.push_to_devices(UserDevice.where(user_id: self.visitor.created_by_id), sendata)
  end

  def host_details
    {
      user_id: user&.id,
      user_name: user&.fullname,
      visitor_id: visitor&.id,
      visitor_name: visitor&.name
    }
  end

end
