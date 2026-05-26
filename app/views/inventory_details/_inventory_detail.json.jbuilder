json.extract! inventory_detail, :id, :item_id, :expected_quantity, :received_quantity, :approved_quantity, :rejected_quantity, :rate, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :inventory_amount, :total_amount, :grn_id, :created_at, :updated_at
json.url inventory_detail_url(inventory_detail, format: :json)
