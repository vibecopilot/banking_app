json.extract! loi_service, :id, :service_detail_id, :product_description, :quantity, :rate, :uom, :expected_date, :amount, :total_amount, :service_order_id, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :created_at, :updated_at
json.service_name SoftService.find_by(id: loi_service.service_detail_id)&.name
json.url loi_service_url(loi_service, format: :json)
