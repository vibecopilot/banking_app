json.extract! business_card, :id, :full_name, :profession, :contact_number, :email_id, :website_url, :address, :created_at, :updated_at
json.url business_card_url(business_card, format: :json)
json.document_url business_card&.image&.document_url