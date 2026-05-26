json.extract! complaint, :id, :id_society, :ticket_number, :id_user, :asset_id, :service_id, :priority, :heading, :text, :active, :action, :IsDelete, :flat_number, :created_at, :updated_at, :issue_type, :issue_status, :is_urgent,:dept_id,:unit_id
json.issue_type complaint.complaint_type.present? ? complaint.complaint_type : ""
json.issue_status complaint.issue_status.present? ? ComplaintStatus.find(complaint.issue_status).try(:name) : ""
json.color_code ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code).present? ? ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code) : "#3d3d3d"    
json.category_type complaint.category_type.present? ? complaint.category_type.name : ""
json.department_name complaint.pms_department.try(:department_name) 
json.unit_name complaint.pms_unit.try(:unit_name) 
json.site_name complaint.pms_site.try(:name)
json.updated_by complaint.user.try(:full_name)
json.posted_by get_complaint_posted_by(complaint)
json.assigned_to complaint.society_staff.try(:staff_user).try(:full_name)
json.complaint_for_type complaint.asset_or_service
json.reopen_status complaint.reopen_status_for_pms
reopen_status = ComplaintStatus.active.find_by(society_id: @user.company_id,fixed_state: "reopen")
json.reopen_status_id reopen_status.try(:id)
json.current_fixed_state complaint.current_fixed_state_for_pms
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
    json.doctype  doc.document_content_type 
    json.document_file_size  doc.document_file_size 
    json.is_liked LikeThing.isliked("Attachfile", doc.id, @user.id).present? ? 1 : 0 
    json.total_likes  LikeThing.total_likes("Attachfile", doc.id)         
  end
end
json.feedbacks do
  json.array! complaint.feedbacks, partial: 'pms/manage/complaints/feedback', as: :osr_log
end