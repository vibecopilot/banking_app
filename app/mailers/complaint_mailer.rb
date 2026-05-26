class ComplaintMailer < ApplicationMailer
  layout false, :only => :daily_report
  #      include Sidekiq::Worker
  #, :admin_new_complaint, :ticket_closed
  def user_new_complaint(complaint)
    @complaint = complaint
    mail(to: @complaint.user.try(:email), from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} has been created : #{@complaint.heading.gsub("\r\n", " ")}")
  end

  def pms_user_new_complaint(complaint)
    @complaint = complaint
    mail(to: @complaint.user.try(:email), from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} has been created : #{@complaint.heading.gsub("\r\n", " ")}")
  end

  def agency_complaint_mail(complaint)
    @complaint = complaint
    @complaint_agency = complaint.supplier.email
    mail(to: @complaint_agency, from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} has been created : #{@complaint.heading.gsub("\r\n", " ")}")
  end

  def ticket_closed(complaint, user)
    @complaint = complaint
    @user = user
    mail(
      to: @user.email,
      subject: "Ticket #{@complaint.ticket_number} has been closed"
    )
  end


  #handle_asynchronously :user_new_complaint
  def status_received(complaint)
    @complaint = complaint
    mail(to: @complaint.user.try(:email), from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} has been Received : #{@complaint.heading.gsub("\r\n", " ")}")
  end
  def admin_new_complaint(complaint, userid)
    @complaint = complaint
    #@user = Spree::User.find(userid)
    mail(to: "noreply@myciti.life", bcc: userid, from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} has been created : #{@complaint.heading.gsub("\r\n", " ")}")
  end

  def pms_admin_new_complaint(complaint, userid)
    @complaint = complaint
    mail(to: "noreply@myciti.life", bcc: userid, from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} has been created : #{@complaint.heading.gsub("\r\n", " ")}")
  end

  def pms_vendor_mail(complaint, userid)
    @complaint = complaint
    mail(to: "noreply@myciti.life", bcc: userid, from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} has been created : #{@complaint.heading.gsub("\r\n", " ")}")
  end

  def pms_assigned_to_complaint_mail(complaint,resptat,resotat)
    @complaint = complaint
    @resptat = resptat
    @resotat = resotat
    @complaint_assigned_to = Spree::User.find_by(id: @complaint.assigned_to)
    mail(to: @complaint.user.try(:email) , from: "noreply@myciti.life", subject: "Your Ticket Number #{@complaint.ticket_number} has been assigned to #{@complaint_assigned_to.full_name}")
  end

  def assigned_to_complaint(complaint)
    @complaint = complaint
    @assignee = @complaint.assigned_to_user
    return unless @assignee&.email.present?
    mail( to: @assignee.email, from: "noreply@myciti.life", subject: "New Complaint Assigned: Ticket #{@complaint.ticket_number}" )
  end

  def pms_complaint_worker_mail(complaint,resptat,resotat)
    @complaint = complaint
    @resptat = resptat
    @resotat = resotat
    @complaint_assigned_to = User.find(complaint.assigned_to)
    mail(to: @complaint_assigned_to.try(:email) , from: "noreply@myciti.life", subject: "Ticket Assignment Details")
  end

  #handle_asynchronously :admin_new_complaint
  def admin_status_change(complaint, email)
    @complaint = complaint
    mail(to: email, from: "noreply@myciti.life", subject: "Status of Helpdesk Ticket #{@complaint.ticket_number} changed")
  end
  #handle_asynchronously :admin_status_change
  def ticket_closed(complaint, userid)
    @complaint = complaint
    @user = Spree::User.find_by(id: userid)
    tpt = @complaint.site_id.present? ? "pms_ticket_closed" : "ticket_closed"
    mail(to: @user.try(:email), from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} is #{@complaint.complaint_status.name.present? ? @complaint.complaint_status.name.titleize : 'closed'} : #{@complaint.heading.gsub("\r\n", " ")}", template_name: "#{tpt}.html.erb")
  end
  #handle_asynchronously :ticket_closed
  def ticket_reopened(complaint, userid)
    @complaint = complaint
    @user = Spree::User.find(userid)
    mail(to: @user.try(:email), from: "noreply@myciti.life", subject: "Helpdesk Ticket #{@complaint.ticket_number} is reopened : #{@complaint.heading.gsub("\r\n", " ")}")
  end
end
