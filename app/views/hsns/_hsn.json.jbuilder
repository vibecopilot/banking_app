json.extract! hsn, :id, :category, :code, :sgst_rate, :cgst_rate, :igst_rate, :active, :updated_by, :company_id, :hsn_type, :created_at, :updated_at
json.created_by_name User.find_by(id: hsn.created_by)&.slice(:firstname, :lastname)
json.url hsn_url(hsn, format: :json)



