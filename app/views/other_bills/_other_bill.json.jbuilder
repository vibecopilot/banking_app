json.extract! other_bill, :id, :vendor_id, :bill_date, :invoice_number, :related_to, :tds_percentage, :retention_percentage, :deduction_remarks, :deduction_amount, :additional_expenses, :payment_tenure, :cgst_rate, :cgst_amount, :sgst_rate, :sgst_amount, :igst_rate, :igst_amount, :tcs_rate,:pan_no, :gst_no, :tcs_amount, :tax_amount, :total_amount, :description,:amount,:base_amount,:tds_rate,:tds_amount, :created_by_id, :created_at, :updated_at
json.suplier_name other_bill.vendor&.vendor_name
json.created_by_name User.find_by(id: other_bill.created_by_id)&.slice(:firstname, :lastname)
json.supplier_details other_bill.vendor

@attachments = Attachfile.where("relation = 'OtherBillDocument' and relation_id = ?", other_bill.id)
json.other_bills_attachments do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

json.url other_bill_url(other_bill, format: :json)