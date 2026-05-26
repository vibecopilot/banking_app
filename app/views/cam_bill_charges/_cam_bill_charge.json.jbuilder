json.extract! cam_bill_charge, :id, :charge_id, :charge_amount, :sub_amount, :cgst_amount, :igst_amount, :sgst_amount, :description, :cam_bill_id, :created_at, :updated_at
json.url cam_bill_charge_url(cam_bill_charge, format: :json)
