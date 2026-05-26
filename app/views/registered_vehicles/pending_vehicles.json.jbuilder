json.total_pages @registered_vehicles.total_pages
json.current_page @registered_vehicles.current_page
json.total_count @registered_vehicles.total_count


json.approvals @registered_vehicles do |approvals|
    json.id approvals.id
    json.name approvals.vehicle_category
    json.approved approvals.approved
    json.vehicle_number approvals.vehicle_number
    json.created_by approvals&.created_by.try(:full_name)
    json.created_at approvals.created_at

    @pending_approvals = Attachfile.where("relation = 'RegisteredVehicleDocument' and relation_id = ?", approvals.id)
    json.registered_vehicle_attachments do
      json.array!(@pending_approvals) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document_url doc.document_url
      end
    end

end