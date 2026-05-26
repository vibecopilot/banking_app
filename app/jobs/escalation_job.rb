require 'sidekiq/api'

class EscalationJob < ActiveJob::Base
  queue_as :default
  self.queue_adapter = :sidekiq

  def perform(cpt)
    ops = HelpdeskOperation.site_ops(cpt.site_id)

    logs = SystemLog.where(log_of: ["HDResolutionJob"], log_of_id: cpt.id)
    ss = Sidekiq::ScheduledSet.new
    logs.each do |lg|
      lg.changed_attr.each do |jid|
        ss.select do |job| 
          if job.args[0]["job_id"] == jid
            job.delete
          end
        end
      end
      lg.delete
    end
    
    respbreached = cpt.esc_histories.ransack(escalation_matrix_complaint_worker_esc_type_eq: "response").result.present?
    if !respbreached
      logs = SystemLog.where(log_of: ["HDResponseJob"], log_of_id: cpt.id)
      ss = Sidekiq::ScheduledSet.new
      logs.each do |lg|
        lg.changed_attr.each do |jid|
          ss.select do |job| 
            if job.args[0]["job_id"] == jid
              job.delete
            end
          end
        end
        lg.delete
      end
      res_jobs = []
      resp_escalations = EscalationMatrix.active.ransack({of_phase_eq: "pms", complaint_worker_esc_type_eq: "response", complaint_worker_assign_nil_or_assign_not_eq: "0", complaint_worker_category_id_eq: cpt.category_type_id, complaint_worker_society_id_eq: cpt.site_id}).result
      resp_escalations.each do |res_esc|
      	esc_on = EscalationMatrix.set_time(res_esc, cpt, ops)
        puts "response_setting_escalation_to #{esc_on}"
      	if esc_on.present?
      		res_job = EscalateComplaintJob.set(wait_until: esc_on).perform_later(cpt.id, res_esc,cpt.priority)
          res_jobs << res_job.job_id
      	end
      end
      SystemLog.create(log_of: "HDResponseJob", log_of_id: cpt.id, changed_attr: res_jobs) if res_jobs.present?
    end

    escalations = EscalationMatrix.joins(:complaint_worker).active.where("complaint_workers.esc_type = 'resolution' or complaint_workers.esc_type is null").search({ complaint_worker_category_id_eq: cpt.category_type_id, complaint_worker_society_id_eq: cpt.site_id}).result.order("escalation_matrices.name asc")

    resolution_jobs = []
    escalations.each do |esc|
      esc_on = EscalationMatrix.set_time(esc, cpt, ops)
      puts "resolution_setting_escalation_to #{esc_on}"
      if esc_on.present?
        resolution_job = EscalateComplaintJob.set(wait_until: esc_on).perform_later(cpt.id, esc,cpt.priority)
        resolution_jobs << resolution_job.job_id
      end
    end
    
    SystemLog.create(log_of: "HDResolutionJob", log_of_id: cpt.id, changed_attr: resolution_jobs) if resolution_jobs.present?

  end
end
