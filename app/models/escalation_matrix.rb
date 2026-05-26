class EscalationMatrix < ApplicationRecord
	serialize :escalate_to_users
	belongs_to :complaint_worker, :foreign_key => :cw_id, class_name: "ComplaintWorker"
	def self.active
		where("active is null or active !=0")
	end

	def escalation_type
		complaint_worker.try(:esc_type) == 'response' ? 'Response' : 'Resolution'
	end

	def elapsed(p)
		if name == "E5"
			EscalationMatrix.where(cw_id: cw_id).where("name = 'E1' or name = 'E2' or name = 'E3' or name = 'E4'").sum(p.to_sym)
		elsif name == "E4"
			EscalationMatrix.where(cw_id: cw_id).where("name = 'E1' or name = 'E2' or name = 'E3'").sum(p.to_sym)
		elsif name == "E3"
			EscalationMatrix.where(cw_id: cw_id).where("name = 'E1' or name = 'E2'").sum(p.to_sym)
		elsif name == "E2"
			EscalationMatrix.where(cw_id: cw_id).where("name = 'E1'").sum(p.to_sym)
		else
			0
		end
	end


	def det_tat(cpt)
		ct = cpt.response_tat_for(cpt.ticket_urgency, cpt.site_id) || 0
		if name == "E5"
			ct * 5
		elsif name == "E4"
			ct * 4
		elsif name == "E3"
			ct * 3
		elsif name == "E2"
			ct * 2
		else
			ct
		end
	end

	def self.startend(dt, ops)
		cdate = dt
		col = dt.strftime("%A").downcase
		day_op = ops[col.to_sym] || {}
		fstart = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op[:start_hour].to_i, day_op[:start_min].to_i).in_time_zone -  5.hours - 30.minutes
		fend = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op[:end_hour].to_i, day_op[:end_min].to_i).in_time_zone -  5.hours - 30.minutes
		return {fstart: fstart, fend: fend}
	end

	def self.determine_time(start, ops, stime, fi = true)
		startend = EscalationMatrix.startend(start.to_date, ops)
		fstart = startend[:fstart]
		fend = startend[:fend]

		if start < fstart
			start = fstart
		end
		dt = start + stime.minutes

		if dt > fend && ops.present?
			startend = EscalationMatrix.startend((start.to_date + 1.day), ops)
			mins = ((fend - start) / 60).to_i
			mins = mins > 0 ? mins : 0
			stime = stime - mins
			EscalationMatrix.determine_time(startend[:fstart], ops, stime, false)
		else
			return dt
		end
	end

	def self.set_time(esc, cpt, ops)
		prt = cpt.priority
		logs = cpt.complaint_logs.ransack(complaint_status_fixed_state_eq: "reopen").result
		category_log = cpt.complaint_logs.ransack(helpdesk_category_id_eq: cpt.category_type_id).result.last
		projectlogs = cpt.complaint_logs.ransack(issue_related_to_eq: "Project").result.last
		fmlogs = cpt.complaint_logs.ransack(issue_related_to_eq: "FM").result.last
		created_time = if cpt.issue_related_to == 'FM' && fmlogs.present?
			fmlogs.created_at
		elsif cpt.issue_related_to == 'Project' && projectlogs.present?
			projectlogs.created_at
		else
			cpt.created_at
		end
		if category_log.present?
			created_time = category_log.created_at
		elsif logs.present?
			lg = logs.last
			created_time = lg.created_at
		end
		puts "created_time======#{created_time}"
		if esc.complaint_worker.try(:esc_type) == "response"
			chkprhrs = esc.det_tat(cpt)
		else
			chkprhrs = (esc[prt.downcase.to_sym] || 0) + esc.elapsed(prt.downcase)
		end
		if chkprhrs > 0
			tm = EscalationMatrix.determine_time(created_time, ops, chkprhrs, true)
			return tm
		end
	end
end
