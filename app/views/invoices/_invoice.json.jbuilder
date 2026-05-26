json.extract! invoice, :id, :prefix, :next_number, :auto_generate, :site_id, :created_by, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
