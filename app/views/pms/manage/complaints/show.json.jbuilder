complaint = @complaint
json.extract! @complaint, :id, :id_society, :ticket_number, :id_user, :priority, :heading, :text, :active, :action, :IsDelete, :flat_number, :created_at, :updated_at, :is_urgent,:dept_id,:unit_id, :category_type_id, :sub_category_id , :proactive_reactive, :root_cause, :impact, :correction, :corrective_action, :territory_manager_id
json.issue_type complaint.complaint_type.present? ? complaint.complaint_type : ""
json.issue_status complaint.issue_status.present? ? ComplaintStatus.find_by_id(complaint.issue_status).try(:name) : ""
json.issue_status_id complaint.issue_status
json.color_code ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code).present? ? ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code) : "#3d3d3d"
json.category_type complaint.category_type.present? ? complaint.category_type.name : ""
json.updated_by complaint.user.try(:full_name)
json.assigned_to complaint.assigned_to.try(:full_name)
json.unit_name complaint.user.try(:unit).try(:name)
json.site_name complaint.try(:site).try(:name)
json.issue_type_id complaint.issue_type_id
json.assigned_to_id complaint.assigned_to
json.reopen_status complaint.reopen_status_for_pms
reopen_status = ComplaintStatus.active.find_by(society_id: @user.company_id,fixed_state: "reopen")
json.reopen_status_id reopen_status.try(:id)
json.current_fixed_state complaint.current_fixed_state_for_pms
json.ticket_urgency complaint.ticket_urgency
json.responsible_person User.find_by(id: complaint.person_id).try(:full_name)
json.category_type complaint.category_type.present? ? complaint.category_type.name : ""
    json.updated_by complaint.complaint_logs.try(:last).try(:user).try(:full_name)
    json.created_by complaint.user.try(:full_name)
    json.unit_name complaint.try(:unit).try(:with_floor_building)
    json.unit complaint.try(:unit).try(:name)
    json.building_name complaint.try(:unit).try(:building).try(:name)
    json.floor_name complaint.try(:unit).try(:floor).try(:name)
    json.sub_category complaint.try(:sub_category).try(:name)
    json.assigned_to User.find_by(id: complaint.assigned_to).try(:full_name)
    json.issue_related_to complaint.try(:issue_related_to)
    json.issue_type_id complaint.issue_type_id
    json.response_breached complaint.response_breached
    json.resolution_breached complaint.resolution_breached
    json.response_time complaint.response_time
    json.resolution_time complaint.resolution_time
    json.ticket_urgency complaint.ticket_urgency


json.complaint_logs do 
  @logs = complaint.complaint_logs  
  json.array!(@logs) do |log|
     json.extract! log, :id, :complaint_id, :complaint_status_id, :changed_by, :priority, :created_at, :updated_at
    complaint_comments = ComplaintComment.where(complaint_log_id: log.id)
    if complaint_comments.present?
      @docs = Attachfile.where("relation = 'ComplaintComment' and relation_id = ?", complaint_comments.last.id)          
    json.log_comment complaint_comments.last.try(:comment) 
    else
    json.log_comment ""
    end
    json.log_status log.complaint_status.try(:name)
    json.log_by log.user.try(:full_name)
    json.documents do
      json.array!(@docs) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document doc.document_url
      end
    end
  end
end
@document = Attachfile.where("relation = 'Complaint' and relation_id = ?", complaint.id)
json.documents do
  json.array!(@document) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
    json.doctype  doc.image_content_type 
    json.document_file_size  doc.image_file_size
  end
end
json.feedbacks do
  json.array! complaint.feedbacks, partial: 'pms/manage/complaints/feedback', as: :osr_log
end
