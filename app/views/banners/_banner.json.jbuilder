json.extract! banner, :id, :title, :description, :site_id, :created_at, :updated_at
json.url banner_url(banner, format: :json)

@banners = Attachfile.where("relation = 'Banner' and relation_id = ?", banner.id)
json.attachments do
  json.array!(@banners) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end
