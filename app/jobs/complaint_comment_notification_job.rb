class ComplaintCommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(complaint_comment_id)
    complaint_comment = ComplaintComment.find_by(id: complaint_comment_id)
    return unless complaint_comment&.complaint.present?
    
    # Get company_id from complaint's site
    company_id = complaint_comment.complaint&.site&.company_id
    
    if company_id.blank?
      Rails.logger.warn "[ComplaintCommentNotificationJob] Cannot send notification: company_id is missing for complaint #{complaint_comment.complaint_id}"
      return
    end
    
    if complaint_comment.changed_by == complaint_comment.complaint.id_user
      admin_users = User.soc_admins
      admin_users.each do |adm|
        sendata = { 
          title: "New Comment", 
          message: "you have new comment for a complaint",  
          ntype: "newcommentbyuser",  
          user_id: adm, 
          complaint_id: complaint_comment.complaint_id, 
          company_id: company_id,
          app_id: complaint_comment.complaint.try(:site_id).present? ? 15 : nil 
        }
        PushNotification.push_to_devices(UserDevice.where(user_id: adm), sendata)
      end
    else
      sendata = { 
        title: "New Comment", 
        message: "you have new comment for a complaint",  
        ntype: "newcommentbyadmin",  
        user_id: complaint_comment.complaint.id_user, 
        complaint_id: complaint_comment.complaint_id,
        company_id: company_id, 
        app_id: complaint_comment.complaint.try(:site_id).present? ? 15 : nil 
      }
      PushNotification.push_to_devices(UserDevice.where(user_id: complaint_comment.complaint.id_user), sendata)
    end
    
    Rails.logger.info "[ComplaintCommentNotificationJob] Notification sent for complaint_comment #{complaint_comment_id}"
  rescue => e
    Rails.logger.error "[ComplaintCommentNotificationJob] Error sending notification: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
