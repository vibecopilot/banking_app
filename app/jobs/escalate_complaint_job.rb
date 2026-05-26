class EscalateComplaintJob < ActiveJob::Base
  queue_as :default
  self.queue_adapter = :sidekiq

  def perform(cid, esc,priority)
    # Do something later
    cpt = Complaint.find(cid)
    if cpt.priority == priority
      proceed = false
      if esc.complaint_worker.esc_type == "resolution"
        if (cpt.complaint_status.fixed_state == nil || (cpt.complaint_status.fixed_state != "closed" && cpt.complaint_status.fixed_state != "complete")) && cpt.complaint_type == "Complaint"
          proceed = true
        end
      else
        if (cpt.complaint_status.name == "Pending" || cpt.complaint_status.fixed_state == "reopen") && (cpt.complaint_type == "Complaint" || cpt.complaint_type == "complaint")
          proceed = true
        end        
      end
      crtdat = cpt.created_at
      @eschistory = EscHistory.where(esc_id: esc.id, complaint_id: cpt.id)
      if esc.escalate_to_users.present? && proceed == true && (esc.active == nil || esc.active == 1) && !@eschistory.present? && cpt.id_society.present?
        esc.escalate_to_users.each do |us|
          usoc = UserSociety.find(us)
          usid = usoc.id_user
          sendata = { title: "#{esc.try(:escalation_type)} - Escalation: complaint pending", message: "status of complaint has not changed since " + crtdat.strftime('%d %m %Y/ %l: %M %p') ,  ntype: "statuschangecomplaint",  user_id: usid, complaint_id: cpt.id }
          PushNotification.push_to_devices(UserDevice.where(user_id: usid), sendata)
          begin
            if cpt.user_society.present? && cpt.user_society.try(:id_society) == 3471
              Spree::EscalationMailer.escalateneelam(cpt, usid, esc).deliver
            elsif cpt.user_society.present?
              Spree::EscalationMailer.escalateother(cpt, usid, esc).deliver
            end
          rescue Exception => e
            puts "#{e.inspect}"
          end
        end
        eh = EscHistory.create(esc_id: esc.id, esc_to: esc.escalate_to_users, complaint_id: cpt.id)
        if esc.complaint_worker.esc_type == "resolution"
          cpt.update_column(:resolution_breached, true)
        else
          cpt.update_column(:response_breached, true)
        end
        SystemLog.newlog(eh, "#{esc.complaint_worker.try(:esc_type).try(:humanize)} Escalation", nil, cpt)
      elsif esc.escalate_to_users.present? && proceed == true && (esc.active == nil || esc.active == 1) && !@eschistory.present? && cpt.site_id.present? 
        esc.escalate_to_users.each do |us|
          sendata = { title: "#{esc.try(:escalation_type)} Escalation: complaint pending", message: "status of complaint has not changed since " + crtdat.strftime('%d %m %Y/ %l: %M %p') ,  ntype: "statuschangecomplaint",  user_id: us, complaint_id: cpt.id, app_id: 15 }
          PushNotification.push_to_devices(UserDevice.where(user_id: us), sendata)
          Spree::EscalationMailer.escalateother(cpt, us, esc).deliver
        end
        eh = EscHistory.create(esc_id: esc.id, esc_to: esc.escalate_to_users, complaint_id: cpt.id)
        if esc.complaint_worker.esc_type == "resolution"
          cpt.update_column(:resolution_breached, true)
        else
          cpt.update_column(:response_breached, true)
        end
        SystemLog.newlog(eh, "#{esc.complaint_worker.try(:esc_type).try(:humanize)} Escalation", nil, cpt)
      end
    else
        return
    end    
  end
end
