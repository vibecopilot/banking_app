json.extract! goods_in_out, :id, :visitor_id,:no_of_goods, :description, :ward_type, :vehicle_no, :person_name, :goods_in_time, :goods_out_time, :staff_id, :created_by_id, :site_id, :item_type, :item_category, :mode_of_transport, :company_name, :department, :reporting_time, :returnable_type, :expected_date, :created_at, :updated_at

json.created_by_name  User.find_by(id: goods_in_out.created_by_id)&.full_name
json.visitor_name goods_in_out.visitor&.try(:name)

if goods_in_out.visitor_id.present?
  json.person_name  Visitor.find_by(id: goods_in_out.visitor_id)&.name
else goods_in_out.staff_id.present?
  json.person_name  Staff.find_by(id: goods_in_out.staff_id)&.full_name
end

json.qr_code_image_url goods_in_out.qr_code_image.try(:document_url)

json.goods_items goods_in_out.goods_items, partial: "goods_items/goods_item", as: :goods_item

json.url goods_in_out_url(goods_in_out, format: :json)
# Fetch attach files related to the GoodsInOut record
@goods_files = Attachfile.where("relation = 'GoodsFile' and relation_id = ?", goods_in_out.id)

json.goods_files do
  json.array!(@goods_files) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.image.url  # Ensure this matches your attribute
  end
end