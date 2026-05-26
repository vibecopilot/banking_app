class ComplaintWorker < ApplicationRecord
	serialize :assign_to
	belongs_to :category, :foreign_key => :category_id, :class_name => "HelpdeskCategory"
	has_many :escalations, :foreign_key => :cw_id, :class_name => "EscalationMatrix", dependent: :destroy
	validates_uniqueness_of :category_id, :scope => [:esc_type]
  	scope :pms, ->{ where(of_phase: "pms") }
  	def validate
  		
  	end

  	def assignee_id
  		assign_to.try(:first)
  	end

	def self.active
		where("assign is null or assign !=0")
	end

	def clone_escalations(region_ids, zone_ids, user_id)
		pms_sites = Pms::Site.ransack({region_id_in: region_ids, zone_id_in: zone_ids}).result
		pms_sites.each do |site|
			cw = self
			new_cw = cw.dup
			new_cw.society_id = site.id
			new_cw.cloned_by_id = user_id
			new_cw.cloned_at = Time.now
			new_cw.escalations = cw.escalations.active.map{|es| es.dup} if cw.escalations.present?
			new_cw.escalations.map{|e| e.society_id = site.id} if new_cw.escalations.present?
			new_cw.save
		end
	end
#ComplaintWorker.escalate_response
	def self.escalate_response
		escalations = EscalationMatrix.active.search({complaint_worker_esc_type_eq: "response", complaint_worker_assign_nil_or_assign_not_eq: "0"}).result
    	escalations.each do |esc|
    		@cw = esc.complaint_worker
	      	complaints = Complaint.search({issue_type_id_eq: @cw.issue_type_id, category_type_id_eq: @cw.category_id, complaint_status_name_eq: "Pending", category_type_tat_not_null: 1}).result.group_by {|c| c.id_society}
	      	complaints.each do |id_society, comps|
		        ops = HelpdeskOperation.soc_ops(id_society)
		        comps.each do |cpt|
		      		eh = EscHistory.where(esc_id: esc.id, complaint_id: cpt.id)
			        if eh.present? 
			          next
			        end
					puts "complaint_checking_is==============#{cpt.id}"
		      		crtdat = cpt.created_at
		      		tat = cpt.category_type.tat
		      		tat = tat * (1 + cpt.esc_histories.count)
		      		chkprhrs = HelpdeskOperation.op_time_passed(cpt, ops)
		      		if chkprhrs >= tat
		      			if esc.escalate_to_users.present?
			      			esc.escalate_to_users.each do |us|
				                usoc = UserSociety.find(us)
				                usid = usoc.id_user
				                sendata = { title: "Escalation: complaint pending", message: "status of complaint has not changed since " + crtdat.to_s ,  ntype: "statuschangecomplaint",  user_id: usid, complaint_id: cpt.id }
				                PushNotification.push_to_devices(UserDevice.where(user_id: usid), sendata)
				                begin		                	
					                if cpt.user_society.present? && cpt.user_society.try(:id_society) == 3471
					                  Spree::EscalationMailer.escalateneelam(cpt, usid, esc).deliver_later
					                elsif cpt.user_society.present?
					                  Spree::EscalationMailer.escalateother(cpt, usid, esc).deliver_later
					                end
				                rescue Exception => e
				                	puts "#{e.inspect}"
				                end
				            end
			              	eh = EscHistory.create(esc_id: esc.id, esc_to: esc.escalate_to_users, complaint_id: cpt.id)
			              	SystemLog.newlog(eh, "Escalation", nil, cpt)
		              	end
		      		end
		      	end
	        end
    	end
	end


	def self.applicable_cw_for(company_id, site_id)
		find_by(society_id: company_id, site_id: site_id) || find_by(society_id: company_id, site_id: nil)
	end
end
