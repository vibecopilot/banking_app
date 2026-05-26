class EscLevel < ApplicationRecord
	serialize :esc_to
	belongs_to :eob_escalation, foreign_key: :esc_id
	before_save :calc_total_minutes


	def calc_total_minutes
		if self.time_in == "days"
			self.total_minutes =1440 * (self.time_val || 0)
		elsif self.time_in == "hours"
			self.total_minutes = 60 * (self.time_val || 0)
		else
			self.total_minutes = self.time_val || 0
		end
	end

	def escalate_eob
		if eob_escalation.active == true
			return
		end

	end

	def time_mins
		if self.time_in == "days"
			return 1440 * (self.time_val || 0)
		elsif self.time_in == "hours"
			return 60 * (self.time_val || 0)
		else
			return self.time_val || 0
		end
	end

	def set_time
		lsp = self.lapsed
		t = total_minutes + lsp
		if t > 0
			return Time.zone.now + t.minutes
		else
			return nil
		end
	end

	def lapsed
		if level ==  "E5"
			EscLevel.where(esc_id: self.esc_id).where("level = 'E1' or level = 'E2' or level = 'E3' or level = 'E4'").sum(:total_minutes)
		elsif level ==  "E4"
			EscLevel.where(esc_id: self.esc_id).where("level = 'E1' or level = 'E2' or level = 'E3'").sum(:total_minutes)
		elsif level ==  "E3"
			EscLevel.where(esc_id: self.esc_id).where("level = 'E1' or level = 'E2'").sum(:total_minutes)
		elsif level ==  "E2"
			EscLevel.where(esc_id: self.esc_id).where("level = 'E1'").sum(:total_minutes)
		else
			0
		end
	end
end
