if @complaint_worker.present?
  json.complaint_worker do
    json.partial! 'complaint_worker', worker: @complaint_worker
  end
elsif @complaint_workers.present?
  json.complaint_workers @complaint_workers do |worker|
    json.partial! 'complaint_worker', worker: worker
  end
  json.total_count @complaint_workers.count
else
  json.error "No complaint workers found"
end