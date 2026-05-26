json.extract! asset_amc, :id, :vendor_id, :asset_id, :start_date, :end_date, :frequency,
                          :first_service, :visits, :amc_cost, :remarks, :created_at, :updated_at
json.asset_name asset_amc.site_asset&.name
json.vendor_name asset_amc.vendor&.vendor_name

@attachments = Attachfile.where("relation = 'AmcTerm' and relation_id = ?", asset_amc.id)
json.attachments do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

@amc_contacts = Attachfile.where(relation: "AmcContact", relation_id: asset_amc.id)
json.amc_contacts do
  json.array!(@amc_contacts) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

@amc_invoices = Attachfile.where(relation: "AmcInvoice", relation_id: asset_amc.id)
json.amc_invoices do
  json.array!(@amc_invoices) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

json.url asset_amc_url(asset_amc, format: :json)
