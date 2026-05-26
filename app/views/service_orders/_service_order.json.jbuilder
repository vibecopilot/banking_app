json.extract! service_order, :id, :pr_no, :service_order_date, :billing_address_id, :retention, :tds, :qc, :payment_tenure, :advance_amount, :related_to, :kind_attention, :subject, :description, :terms_and_conditions, :site_id, :vendor_id, :created_by_id, :reference, :active, :approved_status,  :created_at, :updated_at
json.vendor_name service_order.vendor.vendor_name
json.created_by_name  User.find_by(id: service_order.created_by_id)&.slice(:firstname, :lastname)

@attachments = Attachfile.where("relation = 'ServiceOrderDocument' and relation_id = ?", service_order.id)
json.service_orders_attachfile do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

json.url service_order_url(service_order, format: :json)
@loi_services = service_order.loi_services

json.loi_services do
	json.array! @loi_services do |service|
		json.partial! "loi_services/loi_service", loi_service: service
	end	
end