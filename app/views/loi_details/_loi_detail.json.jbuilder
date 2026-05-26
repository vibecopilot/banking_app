json.extract! loi_detail, :id, :loi_type, :self_id, :pr_no,:reference, :loi_comments, :loi_date, :created_by_id, :billing_address_id, :delivery_address_id, :vendor_id, :transportation_amount, :retention, :tds, :qc, :payment_tenure, :advance_amount, :related_to, :terms, :is_approved, :site_id, :created_at, :updated_at
json.vendor_name loi_detail.vendor&.vendor_name
json.site_name Site.find_by(id:loi_detail.site_id)&.name
json.created_by_name  User.find_by(id: loi_detail.created_by_id)&.slice(:firstname, :lastname)
# @user = User.find_by(id: loi_detail.user_id)
# json.created_by_name @user.try(:firstname, :lastname)

json.billing_address do
  json.extract! loi_detail.billing_address, :id, :address_title, :building_name, :street_name, :state, :city, :pin_code, :phone_number
end

json.delivery_address do
  json.extract! loi_detail.delivery_address, :id, :address_title, :building_name, :street_name, :state, :city, :pin_code, :phone_number
end

@attachments = Attachfile.where("relation = 'LoiDetailDocument' and relation_id = ?", loi_detail.id)
json.loi_details_image do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

json.url loi_detail_url(loi_detail, format: :json)
@loi_items = loi_detail.loi_items
json.loi_items do
  json.array! @loi_items do |item|
    json.partial! "loi_items/loi_item", loi_item: item
  end
end

json.supplier do
  if loi_detail.vendor.present?
    json.partial! "vendors/vendor", vendor: loi_detail.vendor
  end
end

json.approval_logs do
  json.array! loi_detail.approvals, partial: "approvals/approval", as: :approval
end



# json.addresses do
#   json.array! [loi_detail.billing_address, loi_detail.delivery_address].compact.uniq do |address|
#     # json.partial! "addresses/address", address: address
#     json.merge! address.as_json(only: [:id, :address_title, :building_name, :street_name, :state, :city, :pin_code])
#   end
# end
