
json.extract! vendor, :id, :vendor_name, :company_name, :mobile, :email, :site_id, :notes,
              :created_at, :updated_at, :first_name, :last_name, :secondary_mobile,
              :secondary_email, :gstin_number, :pan_number, :address, :active,:status, :country,
              :state, :city, :pincode, :address2, :account_name, :account_number,
              :bank_branch_name, :ifsc_code, :website_url, :district,
              :vendor_supplier_id, :vendor_categories_id,:website_link,:aggrement_start_date,:aggremenet_end_date,:spoc_person
 # Use the correct association names and methods

# Include supplier information
if vendor.vendor_supplier_id.present?
  supplier = GenericSubInfo.find_by(id: vendor.vendor_supplier_id)
  json.supplier do
    json.id supplier.id
    json.name supplier.name
  end
end

# Include category information
if vendor.vendor_categories_id.present?
  category = GenericSubInfo.find_by(id: vendor.vendor_categories_id)
  json.category do
    json.id category.id
    json.name category.name
  end
end

@attachments = Attachfile.where(relation: 'VendorImage', relation_id: vendor.id)
json.attachments @attachments do |attachment|
  json.extract! attachment, :id, :relation, :relation_id
  json.document attachment.document_url
end
json.url vendor_url(vendor, format: :json)
