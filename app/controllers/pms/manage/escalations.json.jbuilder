if @escalation.present?
  json.escalation do
    json.partial! 'escalation', escalation: @escalation
  end
elsif @escalations.present?
  json.escalations @escalations do |escalation|
    json.partial! 'escalation', escalation: escalation
  end
  json.total_count @escalations.count
else
  json.error "No escalations found"
end

if @complaint_worker.present?
  json.complaint_worker do
    json.partial! 'complaint_worker', complaint_worker: @complaint_worker
  end
elsif @complaint_workers.present?
  json.complaint_workers @complaint_workers do |complaint_worker|
    json.partial! 'complaint_worker', complaint_worker: complaint_worker
  end
  json.total_count @complaint_workers.count
end