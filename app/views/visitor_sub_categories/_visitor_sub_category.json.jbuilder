json.extract! visitor_sub_category, :id, :visitor_category_id, :name, :active, :created_at, :updated_at
json.url visitor_sub_category_url(visitor_sub_category, format: :json)


json.iconv2 visitor_sub_category.iconv2&.document_url