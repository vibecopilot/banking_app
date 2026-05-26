json.extract! about, :id, :description, :site_id, :created_at, :updated_at
json.url about_url(about, format: :json)
json.site_name about.site.try(:name)

@images = Attachfile.where(relation: 'About', relation_id: about.id)
json.attachments do
  json.array! @images do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end
