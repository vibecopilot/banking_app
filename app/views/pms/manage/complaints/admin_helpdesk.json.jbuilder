json.complaints do
  json.array!(@complaints) do |complaint|
    json.extract! complaint, :id, :id_user, :ticket_number, :priority, :heading, :text, :active, :action, :IsDelete, :created_at, :updated_at, :is_urgent, :dept_id,:unit_id, :site_id
    json.issue_type complaint.complaint_type.present? ? complaint.complaint_type : ""
    json.issue_status complaint.issue_status.present? ? ComplaintStatus.find_by(id: complaint.issue_status).try(:name) : ""
    json.color_code ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code).present? ? ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code) : "#3d3d3d"
    json.category_type complaint.category_type.present? ? complaint.category_type.name : ""
    json.updated_by complaint.user.try(:full_name)
    json.assigned_to complaint.assigned_to.try(:full_name)
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
          json.log_status complaint.complaint_status.try(:name)
          json.log_by complaint.user.try(:full_name)
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
  end
end
