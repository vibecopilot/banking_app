json.extract! contact_book, :id, :company_name, :contact_person_name, :site_id, :generic_info_id, :generic_sub_info_id, :mobile, :landline_no, :primary_email, :secondary_email, :website, :address, :key_offering, :description, :profile, :status, :created_at, :updated_at
json.generic_info_name contact_book.generic_info&.name
json.generic_sub_info_name contact_book.generic_info&.generic_sub_infos&.find_by(id: contact_book.generic_sub_info_id)&.name
json.url contact_book_url(contact_book, format: :json)

@insurances = contact_book&.logo
json.logo do
  json.array!(@insurances) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

@attachments = contact_book&.attachments
json.contact_books_attachment do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end