module Spree
  class EscalationMailer < BaseMailer
    def escalateother(complaint, usid, esc)
      @complaint = complaint
      @user = Spree::User.find(usid)
      @name = @user.full_name
      @esc = esc
      @email = @user.email
      @cl = @complaint.complaint_logs.last
      mail(to: @email, from: "noreply@myciti.life", subject: "#{@esc.escalation_type} - Escalation #{@esc.name} - Helpdesk Ticket Number #{@complaint.ticket_number}")
    end
  	def escalateneelam(complaint, usid, esc)
      @complaint = complaint
      @user = Spree::User.find(usid)
  		@name = @user.full_name
  		@email = @user.email
      @cl = @complaint.complaint_logs.last
		mail(to: @email, from: "senroof@neelamrealtors.com", subject: "Helpdesk Ticket #{@complaint.ticket_number}  #{esc.try(:escalation_matrix).try(:complaint_worker).try(:esc_type)} Escalation : #{@complaint.heading}")
	end
  end
end