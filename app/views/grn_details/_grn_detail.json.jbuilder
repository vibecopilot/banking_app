json.extract! grn_detail, :id, :grn_unique_id, :loi_detail_id, :vendor_id, :payment_mode, :invoice_number, :related_to, :invoice_amount, :invoice_date, :posting_date, :other_expenses, :loading_expenses, :adjustment_amount, :notes, :created_at, :updated_at
json.url grn_detail_url(grn_detail, format: :json)

json.vendor_name grn_detail&.vendor&.try(:vendor_name)
json.created_by grn_detail&.created_by&.try(:full_name)

json.inventory_details do
  json.array! grn_detail.inventory_details do |inventory_detail|
    json.extract! inventory_detail, :id, :item_id, :expected_quantity, :received_quantity, :approved_quantity, :rejected_quantity, :rate, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :inventory_amount, :total_amount, :grn_id, :inventory_type, :criticality, :batches, :created_at, :updated_at
    json.inventory_name inventory_detail.item.try(:name)
    json.url inventory_detail_url(inventory_detail, format: :json)
  end
end