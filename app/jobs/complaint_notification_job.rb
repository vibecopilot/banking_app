class ComplaintNotificationJob < ApplicationJob
  queue_as :default

  def perform(complaint_id, event_type = 'create')
    complaint = Complaint.find_by(id: complaint_id)
    return unless complaint

    Rails.logger.info("Sending notifications for Complaint #{complaint_id}, event: #{event_type}")
    
    company_id = complaint.site&.company_id || complaint.assigned_to_user&.site&.company_id

    # Build notification payload based on event type
    if event_type == 'status_change'
      status_name = ComplaintStatus.find_by_id(complaint.issue_status).try(:name)
      sendata = {
        title: "Ticket #{complaint.ticket_number} Status Updated",
        message: "Ticket #{complaint.ticket_number} is now #{status_name}",
        created_by: complaint.user.try(:full_name),
        ntype: "statuschangecomplaint",
        status_name: status_name,
        company_id: company_id,
        record_id: complaint.id,
        complaint_id: complaint.id
      }
    else
      sendata = {
        title: "Ticket #{complaint.ticket_number} Created",
        message: "New Ticket: #{complaint.heading} of priority #{complaint.priority} is Created",
        created_by: complaint.user.try(:full_name),
        ntype: complaint.complaint_type,
        company_id: company_id,
        record_id: complaint.id
      }
    end

    # Notify assigned user
    Rails.logger.info("Complaint notification payload: #{sendata}")
    if complaint.assigned_to.present?
      PushNotification.push_to_devices(UserDevice.where(user_id: complaint.assigned_to), sendata)
    end

    # Notify site admins
    if complaint.site_id.present?
      admin_user_ids = UserSite.where(site_id: complaint.site_id).pluck(:user_id)
      admin_user_ids = User.where(id: admin_user_ids, user_type: ["pms_admin"]).pluck(:id)
      
      if admin_user_ids.any?
        admin_sendata = if event_type == 'status_change'
          {
            title: "Complaint Status Updated",
            message: "Ticket #{complaint.ticket_number} status changed to #{ComplaintStatus.find_by_id(complaint.issue_status).try(:name)}",
            ntype: "complaint",
            status_name: ComplaintStatus.find_by_id(complaint.issue_status).try(:name),
            complaint_id: complaint.id,
            of_phase: complaint.of_phase,
            company_id: company_id,
            record_id: complaint.id
          }
        else
          {
            title: "New Complaint",
            message: "User has created a ticket of type #{complaint.complaint_type} has Ticket-ID #{complaint.id}",
            ntype: "complaint",
            complaint_id: complaint.id,
            of_phase: complaint.of_phase,
            company_id: company_id,
            record_id: complaint.id
          }
        end

        Rails.logger.info("Admin notification for #{admin_user_ids.count} users: #{admin_sendata}")
        PushNotification.push_to_devices(UserDevice.where(user_id: admin_user_ids), admin_sendata)
      end
    end
  end
end
