json.count @complaints.respond_to?(:total_entries) ? @complaints.total_entries : (@complaints.respond_to?(:size) ? @complaints.size : 0)
json.total_pages @complaints.respond_to?(:total_pages) ? @complaints.total_pages : 1
json.current_page @complaints.respond_to?(:current_page) ? @complaints.current_page : 1
if @filtered_counts.present?
  json.filtered_counts do
    json.total @filtered_counts[:total]
    json.by_status @filtered_counts[:by_status]
    json.by_type @filtered_counts[:by_type]
  end
end
json.complaints do
  if @complaints.respond_to?(:each)
    json.array!(@complaints) do |complaint|
      json.extract! complaint, :id, :id_user, :ticket_number, :priority, :heading, :text, :active, :action, :IsDelete, :created_at, :updated_at, :is_urgent, :dept_id,:unit_id, :site_id
      json.issue_type complaint.complaint_type.present? ? complaint.complaint_type : ""
      # json.issue_status complaint.issue_status.present? ? ComplaintStatus.find(complaint&.issue_status).try(:name) : ""
      json.issue_status ComplaintStatus.find_by(id: complaint.issue_status)&.name || ""
      # json.color_code ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code).present? ? ComplaintStatus.find_by_id(complaint.issue_status).try(:color_code) : "#3d3d3d"
      json.color_code ComplaintStatus.find_by(id: complaint.issue_status)&.color_code || "#3d3d3d"
      json.category_type complaint.category_type.present? ? complaint.category_type.name : ""
      json.updated_by complaint.complaint_logs.try(:last).try(:user).try(:full_name)
      json.created_by complaint.user.try(:full_name)
      json.complaint_mode complaint.complaint_mode.try(:name)
      json.unit_name complaint.try(:unit).try(:with_floor_building)
      json.unit complaint.try(:unit).try(:name)
      json.unit_id complaint.try(:unit)&.id
      json.building_name complaint.try(:unit).try(:building).try(:name)
      json.building_id complaint.try(:unit).try(:building)&.id
      json.floor_name complaint.try(:unit).try(:floor).try(:name)
      json.floor_id complaint.try(:unit).try(:floor)&.id
      json.site_name complaint.try(:site).try(:name)
      json.sub_category complaint.try(:sub_category).try(:name)
      json.sub_category_id complaint.try(:sub_category)&.id
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
          json.log_status complaint.complaint_status.try(:name)
          json.log_by log.user.try(:full_name)
          json.documents do
            json.array!(@docs) do |doc|
              json.extract! doc, :id, :relation, :relation_id
              json.document doc.document_url
            end
          end
        end
     end

      @docs = Attachfile.where("relation = 'Complaint' and relation_id = ?", complaint.id)
      json.documents do
        json.array!(@docs) do |doc|
          json.extract! doc, :id, :relation, :relation_id
          json.document doc.document_url
          json.doctype  doc.image_content_type
          json.document_file_size  doc.image_file_size
        end
      end
    end
  else
    json.array! []
  end
end


