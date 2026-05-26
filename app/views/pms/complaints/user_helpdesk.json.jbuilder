json.total_pages @complaints.total_pages
json.current_page @complaints.current_page

json.complaints do
  json.array!(@complaints) do |complaint|
    json.extract! complaint, :id, :id_society, :id_user,:asset_id, :ticket_number, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type, :issue_status, :created_at, :updated_at, :is_urgent
    # json.url complaint_url(complaint, format: :json)
    json.category_type complaint.category_type.name
    json.updated_by get_complaint_updated_by(complaint)
    json.posted_by get_complaint_posted_by(complaint)
    @docs = Attachfile.where("relation = 'Complaint' and relation_id = ?", complaint.id)
    json.documents do
      json.array!(@docs) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document doc.document_url
      end
    end
  end
end