json.extract! other_project, :id, :title, :description, :address, :company_id, :contact_us, :created_at, :updated_at
json.url other_project_url(other_project, format: :json)
@pdf = Attachfile.where("relation = 'OtherProjectPDF' and relation_id = ?", other_project.id)

@attachments = Attachfile.where("relation = 'OtherProject' and relation_id = ?", other_project.id)
json.attachments do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end
json.pdf do
  json.array!(@pdf) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

json.liked_count other_project.likes.liked.count
json.likes do
  json.array! other_project&.likes&.liked do |like|
    json.user_id like&.user_id
    json.full_name like&.user&.full_name  
    json.mobile like&.user&.mobile
    json.email like&.user&.email
  end
end

json.contact_us other_project.contact_us

json.other_p_amenities do
  json.array! other_project.other_p_amenities do |amenity|
    json.extract! amenity, :id, :name
    json.icon_url amenity.amenity_icon&.document_url
  end
end