json.extract! transportation, :id, :on_behalf_of, :pickup_location, :dropoff_location, :date, :time, :no_of_passengers, :additional_note, :transportation_type, :created_at, :updated_at, :mobile_no, :user_full_name, :created_by_full_name
@attached_files = Attachfile.where(relation: 'Transportation', relation_id: transportation.id)
json.attachments do
  json.array! @attached_files do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end
json.url transportation_url(transportation, format: :json)
