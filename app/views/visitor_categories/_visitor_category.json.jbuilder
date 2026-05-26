json.extract! visitor_category, :id, :name, :code, :active, :created_at, :updated_at
json.url visitor_category_url(visitor_category, format: :json)

json.icon visitor_category.icon&.document_url
