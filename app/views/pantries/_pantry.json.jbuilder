json.extract! pantry, :id, :item_name, :stock, :description, :created_by_id, :status, :created_at, :updated_at
json.ordered_by_name User.find_by(id: pantry.created_by_id)&.slice(:firstname, :lastname)

@attachments = Attachfile.where("relation = 'PantryDocument' and relation_id = ?", pantry.id)
json.pantries_attachments do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end
json.url pantry_url(pantry, format: :json)
