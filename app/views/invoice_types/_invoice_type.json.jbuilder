json.extract! invoice_type, :id, :name, :created_by_id, :site_id, :created_at, :updated_at
json.url invoice_type_url(invoice_type, format: :json)
