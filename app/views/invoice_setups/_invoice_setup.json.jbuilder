json.extract! invoice_setup, :id, :prefix, :next_number, :auto_generate, :site_id, :created_by, :created_at, :updated_at, :online_payment_allowed
json.url invoice_setup_url(invoice_setup, format: :json)
