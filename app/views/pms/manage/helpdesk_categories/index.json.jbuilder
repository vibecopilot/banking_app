json.array! @helpdesk_categories do |helpdesk_category|
  json.id helpdesk_category.id
  json.name helpdesk_category.name
  json.society_id helpdesk_category.society_id
  json.position helpdesk_category.position
  json.tat helpdesk_category.tat
  json.active helpdesk_category.active
  json.of_phase helpdesk_category.of_phase
  json.icon helpdesk_category.icon
  json.response_tat helpdesk_category.response_tat

  # Include associated complaint worker information if available
  # if helpdesk_category.complaint_worker.present?
  #   json.complaint_worker do
  #     json.id helpdesk_category.complaint_worker.id
  #     json.assign_to helpdesk_category.complaint_worker.assign_to

  #     # Fetch and include the name of the assigned entity (assuming assign_to is a User ID)
  #     assigned_user = User.find_by(id: helpdesk_category.complaint_worker.assign_to)
  #     if assigned_user
  #       json.assign_to_name assigned_user.full_name # Use the correct attribute name
  #     else
  #       json.assign_to_name nil
  #     end
  #   end
  # end

  if helpdesk_category.complaint_worker.present?
  json.complaint_worker do
    json.id helpdesk_category.complaint_worker.id
    json.assign_to helpdesk_category.complaint_worker.assign_to

    assigned_users = User.where(id: helpdesk_category.complaint_worker.assign_to)

    json.assign_to_details assigned_users.map { |user|
      {
        id: user.id,
        name: user.full_name 
      }
    }
  end
end


  @attachments = Attachfile.where("relation = 'HelpdeskCategoryIcon' and relation_id = ?", helpdesk_category.id)
  json.helpdesk_categorys_image do
    json.array!(@attachments) do |doc|
      json.extract! doc, :id, :relation, :relation_id
      json.document doc.document_url
    end
  end


  # Include associated sub-categories if available
  json.sub_categories do
    json.array! helpdesk_category.helpdesk_sub_categories do |sub_category|
      json.id sub_category.id
      json.name sub_category.name
    end
  end

  json.created_at helpdesk_category.created_at
  json.updated_at helpdesk_category.updated_at
end