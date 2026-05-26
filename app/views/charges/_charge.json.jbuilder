json.extract! charge, :id, :site_id, :name, :code, :cgst, :sgst, :igst, :created_at, :updated_at
json.url charge_url(charge, format: :json)
