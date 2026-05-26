json.extract! cam_bill, :id, :unit_id, :user_id, :bill_date, :due_date, :created_by, 
                      :sub_amount, :created_at, :updated_at, :invoice_type, :invoice_address_id, 
                      :invoice_number, :building_id, :flat_id, :due_amount, :due_amount_interst, 
                      :note, :bill_period_start_date, :bill_period_end_date, :supply_date, 
                      :floor_id, :status, :recall_reason
json.payment_status cam_bill&.payment_status
json.amount_paid Payment.where("resource_type = 'CamBill' and resource_id = ?", cam_bill.id)&.sum(:total_amount)
json.url cam_bill_url(cam_bill, format: :json)
total_value_sum = 0

json.charges cam_bill.cam_bill_charges do |charge|

  json.extract! charge, :id, :charge_id, :charge_amount, :sub_amount, :cgst_amount, :sgst_amount, 
                        :igst_amount, :cgst_rate, :sgst_rate, :igst_rate, :description, 
                        :discount_percent, :quantity, :unit, :rate, :hsn_id, :taxable_value, 
                        :created_at, :updated_at, :total_value, :total, :discount_amount
  total_value_sum += charge.total.to_f
end

json.flat cam_bill.unit

totals = total_value_sum + cam_bill.try(:due_amount).to_f + cam_bill.try(:due_amount_interst).to_f
json.total_amount totals
json.total_charge total_value_sum
json.building do
    json.partial! "buildings/building", building: cam_bill&.building if cam_bill&.building.present?
end
json.reciever_details cam_bill.user if cam_bill.user.present?
json.address_details cam_bill.address if cam_bill.address.present?

@invoices = InvoiceReceipt.where("resource_type = 'CamBill'and resource_id = ?", cam_bill.id)
json.invoice_receipts do
  json.array!(@invoices) do |invoice|

    json.extract! invoice, :id, :receipt_number, :invoice_number, :building_id, :unit_id, :address_id, :payment_mode, :amount_received, :transaction_or_cheque_number, :bank_name, :branch_name, :payment_date, :receipt_date, :notes, :created_at, :updated_at, :cam_bill_id
    json.customer_name cam_bill&.user&.full_name
    json.building_name cam_bill&.building&.name
    json.unit_name cam_bill&.unit&.name
    json.address_details cam_bill&.address
    # json. cam_bill&.user&.full_name
    if invoice&.cam_bill&.present?
      # Building condition
      json.building do
        json.partial! "buildings/building", building: invoice&.cam_bill&.building if invoice&.cam_bill&.building.present?
      end

      # Unit condition
      json.unit do
        json.partial! "units/unit", unit: invoice&.cam_bill&.unit if invoice&.cam_bill&.unit.present?
      end

      # Address condition
      json.address_setup do
        json.partial! "address_setups/address_setup", address_setup: invoice&.cam_bill&.address if invoice&.cam_bill&.address.present?
      end
    else
      json.building {}
      json.unit {}
      json.address_setup {}
    end
  end
end


@payments = Payment.where("resource_type = 'CamBill' and resource_id = ?", cam_bill.id)
json.payments do
  json.array!(@payments) do |payment|
    json.extract! payment,:id, :resource_id, :resource_type, :total_amount, :paid_amount, :user_id, :payment_method, :transaction_id, :paymen_date, :created_at, :updated_at, :notes
    json.image_url Attachfile.find_by(relation: "CamPayment",relation_id: payment.id)&.document_url
  end
end
