json.extract! loi_item, :id, :loi_detail_id, :item_id, :sac_code, :quantity, :standard_unit_id, :expected_date, :rate, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :amount, :total_amount, :created_at, :updated_at
json.item_name loi_item.item&.name
json.standard_unit_name loi_item.standard_unit&.unit_name
json.url loi_item_url(loi_item, format: :json)
