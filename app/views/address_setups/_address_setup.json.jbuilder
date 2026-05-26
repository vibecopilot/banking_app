json.extract! address_setup, :id, :title, :address, :building_id, :state, :phone_number, :fax_number, :email_address, :registration_no, :pan_number, :cheque_in_favour_of, :gst_number, :account_number, :account_type, :ifsc_code, :account_name, :bank_branch_name, :site_id, :created_at, :updated_at
json.url address_setup_url(address_setup, format: :json)

@cover_images = Attachfile.where(relation: 'AddressSetup', relation_id: address_setup.id)
json.attachments do
  json.array!(@cover_images) do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end