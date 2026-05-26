json.extract! supplier, :id, :name, :contact_person, :email, :phone, :address, :status, :site_id, :created_by_id, :created_at, :updated_at
json.url supplier_url(supplier, format: :json)
