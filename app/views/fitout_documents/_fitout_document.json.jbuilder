json.extract! fitout_document, :id, :fitout_request_id, :active, :name, :created_at, :updated_at
json.url fitout_document_url(fitout_document, format: :json)

json.fitout_docs fitout_document.fitout_docs do |file|
  json.extract! file, :id, :relation, :relation_id, :created_at, :updated_at
  json.document_url file.document_url 
end
