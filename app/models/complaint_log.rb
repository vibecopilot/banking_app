class ComplaintLog < ApplicationRecord
	belongs_to :complaint
  belongs_to :helpdesk_category, optional: true
	belongs_to :complaint_status, optional: true
  belongs_to :assigned, class_name: "User",:foreign_key => :assigned_to, optional: true

	belongs_to :user, :foreign_key => :changed_by, class_name: 'User'
  has_many :complaint_comments 
	delegate :name, to: :complaint_status, allow_nil: true



	after_create :send_notification_to_user	
  before_create :check_last_log
  after_create :update_sub_category
  serialize :update_params
  def check_last_log
    if ComplaintLog.where(complaint_id: self.complaint_id).present?
      log = self.complaint #ComplaintLog.where(complaint_id: self.complaint_id).try(:last)
      logstatus = log.issue_status
    else
      log = ComplaintLog.where(complaint_id: self.complaint_id).try(:last)
      logstatus = log.try(:complaint_status_id)
    end
    if log.present?
      log.society_staff_type = self.society_staff_type
      if self.priority.present? && self.priority == log.priority
        self.priority = nil
      end
      
      if self.assigned_to.present? && self.assigned_to == log.assigned_to
        self.assigned_to = nil
      end
      if self.complaint_status_id.present? && self.complaint_status_id == logstatus.to_i
        self.complaint_status_id = nil
      end
    end
  end


  def update_sub_category
    if self.sub_category_id.present?
        # self.complaint.update_attribute('sub_category_id' , self.sub_category_id)    
    end 
  end

  
	def send_notification_to_user
        oldc = self.complaint
        if self.priority.present?
          # @complaint =   self.complaint.update_attribute('priority' , self.priority)
      	  sendata = { title: "Changes made: ", message: "Priority of your Ticket is changed",  ntype: "statuschangecomplaint",  user_id: self.complaint.id_user, complaint_id: self.complaint_id }
          #notification = true if self.changed_by != nil #&& self.complaint.priority != oldc.priority
        end
      	if self.assigned_to.present?
      		# @complaint =   self.complaint.update_attribute('assigned_to' , self.assigned_to)
      	  sendata = { title: "Changes made: ", message: "Worker of your Ticket is changed",  ntype: "statuschangecomplaint",  user_id: self.complaint.id_user, complaint_id: self.complaint_id }
          ss = self.complaint.try(:assigned_to)
          if ss.present? && self.complaint.assigned_to != oldc.assigned_to
            sendatawork= { title: "Ticket is assigned to you", message: "You are assigned with a new complaint",  ntype: "statuschangecomplaint",  user_id: ss, complaint_id: self.complaint_id, app_id: self.complaint.try(:site_id).present? ? 15 : nil }
            PushNotification.push_to_devices(UserDevice.where(user_id: ss), sendatawork)
          end
          notification = true #if self.complaint.assigned_to != oldc.assigned_to
        end
        
        if self.complaint_status_id.present? && self.changed_by.present?
           @complaint =  self.complaint.update_column(:issue_status, self.complaint_status_id)
           if self.complaint_status && self.complaint_status.fixed_state == "closed"
             sendata = { title: "Changes made: ", message: "Ticket #{self.complaint.ticket_number} is closed ",  ntype: "statuschangecomplaint",  user_id: self.complaint.id_user, complaint_id: self.complaint_id }
             if self.complaint.site_id.present? && self.complaint.user.present? 
              ComplaintMailer.ticket_closed(self.complaint, self.complaint.id_user).deliver_later(wait_until: 1.minute.from_now)
             elsif self.complaint.id_society.present?
              ComplaintMailer.ticket_closed(self.complaint, self.complaint.id_user).deliver_later(wait_until: 1.minute.from_now)
              end
           elsif self.complaint_status && self.complaint_status.fixed_state == "reopen"
            EscalationJob.set(wait_until: Time.zone.now + 1.minute).perform_later(self.complaint)
             sendata = { title: "Changes made: ", message: "Ticket #{self.complaint.ticket_number} is reopened ",  ntype: "statuschangecomplaint",  user_id: self.complaint.id_user, complaint_id: self.complaint_id }
             # ComplaintMailer.ticket_reopened(self.complaint, self.complaint.id_user).deliver_later if self.complaint.id_society.present? || (self.complaint.site_id.present? && self.complaint.user.active_lup?(self.complaint.site.company_id))
           else
              sendata = { title: "Changes made: ", message: "Status of Ticket #{self.complaint.ticket_number} is changed ",  ntype: "statuschangecomplaint",  user_id: self.complaint.id_user, complaint_id: self.complaint_id }
           end

           # if self.complaint_status.try(:fixed_state) == "complete"
           #    if self.complaint.site_id.present?
           #      set_site_auto_close_job
           #    else
           #      set_society_auto_close_job
           #    end
           #  end
            # admin_users = UserSociety.soc_admins(self.complaint.id_society)
            # admin_users = User.where('user_type IN (?) ', ["pms_admin", "pms_organization_admin"])
            admin_users = User.where(id: UserSite.where(site_id: self.complaint.site_id).pluck(:user_id)).where(user_type: ["pms_admin", "pms_organization_admin"])
            
            
            admin_users.each_with_index do |adm, i|
              sendata2 = { title: "Changes made: ", message: "Status of Ticket is changed",  ntype: "statuschangecomplaintadmin",  user_id: adm, complaint_id: self.complaint_id }
              if self.complaint_status.try(:fixed_state) == "closed"
                ComplaintMailer.ticket_closed(self.complaint, adm).deliver_later(wait_until: 1.minute.from_now)
              elsif self.complaint_status.try(:fixed_state) == "reopen"
                sendata2[:title] = "Ticket Reopened"
                sendata2[:message] = "Ticket #{oldc.ticket_number} is Reopened"
                ComplaintMailer.ticket_reopened(self.complaint, adm).deliver_later
              end

              PushNotification.push_to_devices(UserDevice.where(user_id: adm), sendata2)
            end
          notification = true if self.changed_by != nil #&& self.complaint.assigned_to != oldc.assigned_to
        end	


      if notification.present? || self.comment.present?
        if !notification.present?
              sendata = { title: "Comment Added", message: "#{self.comment}",  ntype: "complaint", record_id: self.complaint_id, company_id: self.complaint&.site&.company_id }
            end
        PushNotification.push_to_devices(UserDevice.where(user_id: [self.complaint.id_user, self.complaint.assigned_to]), sendata) if self.complaint.id_society.present? || (self.complaint.id_user.present? && self.complaint.site_id.present? )
      end
      SystemLog.newlog(self, "Log", nil, self.complaint)
	end

  def set_site_auto_close_job
    # cs = ComplaintStatus.pms.active.where(society_id: self.complaint.site.company_id,fixed_state: "closed").first  
    # close_time = self.complaint.complaint_logs.last.created_at
    # # reopenstatus = ReopenStatus.find_by(society_id: self.complaint.site.company_id) 
    # if reopenstatus.try(:time_seconds).present?
    #   closure_time = close_time + reopenstatus.time_seconds
    #   if cs.present? && closure_time.present?
    #     TicketStatusClosedJob.set(wait_until: closure_time).perform_later(self.complaint, cs)
    #   end  
    # end
  end


  def set_society_auto_close_job
    # if self.complaint.society.auto_complaint_close?
    #   cs = ComplaintStatus.post_possession.active.where(society_id: self.complaint.id_society,fixed_state: "closed").first
    #   close_time = self.complaint.complaint_logs.last.created_at
    #   # reopenstatus = ReopenStatus.find_by(society_id: self.complaint.id_society) 
    #   if reopenstatus.try(:time_seconds).present?
    #     closure_time = close_time + reopenstatus.time_seconds
    #     if cs.present? && closure_time.present?
    #       TicketStatusClosedJob.set(wait_until: closure_time).perform_later(self.complaint,cs)
    #     end
    #   end
    # end
  end


  private

  def validate_reopen_time
    if self.complaint_status.present? && self.complaint_status.fixed_state == "reopen" && complaint.closure_date.present? && complaint.formatted_reopen_time.present? && complaint.closure_date.advance(minutes: complaint.formatted_reopen_time) < Time.now
      errors.add(:complaint, "The time set for reopening the ticket has elapsed. Hence the ticket cannot be reopened")
    end
  end
end
