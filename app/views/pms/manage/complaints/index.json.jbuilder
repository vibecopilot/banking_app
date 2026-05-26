json.array!(@complaints) do |complaint|
  json.extract! complaint, :id, :id_society, :id_user, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type, :issue_status, :dept_id, :unit_id, :created_at, :updated_at
  json.url complaint_url(complaint, format: :json)
  json.category_type complaint.category_type.name
  json.updated_by complaint.user.try(:firstname)
  @docs = Attachfile.where("relation = 'Complaint' and relation_id = ?", complaint.id)
    json.documents do
      json.array!(@docs) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document doc.document_url
      end
    end
end
