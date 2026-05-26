json.extract! invoice_receipt, :id, :receipt_number, :invoice_number, :building_id, :unit_id, :address_id, 
  :payment_mode, :amount_received, :transaction_or_cheque_number, :bank_name, :branch_name, :payment_date, 
  :receipt_date, :notes, :created_at, :updated_at, :cam_bill_id, :vendor_id, :resource_type, :resource_id

json.url invoice_receipt_url(invoice_receipt, format: :json)

# Ensure cam_bill exists before accessing attributes
if invoice_receipt.cam_bill.present?
  # Building condition
  json.building do
    json.partial! "buildings/building", building: invoice_receipt.cam_bill.building if invoice_receipt.cam_bill.building.present?
  end

  # Unit condition
  json.unit do
    json.partial! "units/unit", unit: invoice_receipt.cam_bill.unit if invoice_receipt.cam_bill.unit.present?
  end

  # Address condition
  json.address_setup do
    json.partial! "address_setups/address_setup", address_setup: invoice_receipt.cam_bill.address if invoice_receipt.cam_bill.address.present?
  end
else
  json.building {}
  json.unit {}
  json.address_setup {}
end
