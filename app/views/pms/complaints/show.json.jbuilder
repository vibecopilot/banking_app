json.extract! @complaint, :id, :id_society, :id_user, :asset_id, :heading, :text, :active, :action, :IsDelete, :flat_number, :created_at, :updated_at, :issue_type_id, :issue_status, :is_urgent
json.ticket_urgency @complaint.ticket_urgency
json.complaint_mode @complaint.complaint_mode&.name

json.posted_by @complaint.user&.full_name
@docs = Attachfile.where("relation = 'Complaint' and relation_id = ?", @complaint.id)
    json.documents do
      json.array!(@docs) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document doc.document_url
      end
    end