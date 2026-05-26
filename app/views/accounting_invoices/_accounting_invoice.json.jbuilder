json.extract! accounting_invoice, :id, :invoice_number, :invoice_date, :due_date, :invoice_type, :source_type,
                :subtotal, :tax_amount, :total_amount, :paid_amount, :balance_amount, :amount, :payment_mode, :payment_ref_no,
                :status, :notes, :terms_and_conditions, :sent_at, :paid_at, :created_at, :updated_at,
                :customer_name, :customer_email, :customer_address, :gst_no, :unit_no,
                :bank_account, :bank_ifsc, :bank_aic, :gst_reverse_charge, :place_of_supply, :state, :state_code,
                :gst_input_value, :income_month, :income_year

json.site do
  if accounting_invoice.site
    json.extract! accounting_invoice.site, :id, :name
  end
end

json.unit do
  if accounting_invoice.unit
    json.extract! accounting_invoice.unit, :id, :name
    json.building_name accounting_invoice.unit.building&.name
    json.floor_name accounting_invoice.unit.floor&.name
    json.full_address accounting_invoice.unit.full_address
  else
    json.nil!
  end
end

json.user do
  if accounting_invoice.user
    json.extract! accounting_invoice.user, :id, :firstname, :lastname, :email, :mobile
  else
    json.nil!
  end
end

json.vendor do
  if accounting_invoice.vendor
    json.extract! accounting_invoice.vendor, :id, :vendor_name
  else
    json.nil!
  end
end

json.created_by do
  if accounting_invoice.created_by
    json.extract! accounting_invoice.created_by, :id, :firstname, :lastname, :email
  end
end

json.overdue accounting_invoice.overdue?
json.days_overdue accounting_invoice.days_overdue

json.accounting_invoice_items accounting_invoice.accounting_invoice_items do |item|
  json.extract! item, :id, :description, :quantity, :unit_price, :amount, :tax_amount, :total_amount, :item_type, :notes,
                :s_no, :service_description, :service_details, :hsn_sac_code, :rate, :taxable_value,
                :cgst_rate, :cgst_amount, :sgst_rate, :sgst_amount, :igst_rate, :igst_amount, :total, :tax_rate_id, :gst_type
  json.ledger do
    if item.ledger
      json.extract! item.ledger, :id, :name, :code
    else
      json.nil!
    end
  end
  json.tax_rate do
    if item.tax_rate
      json.extract! item.tax_rate, :id, :name, :rate, :tax_type
    else
      json.nil!
    end
  end
end

json.payments_count accounting_invoice.accounting_payments.count

json.payments accounting_invoice.accounting_payments do |payment|
  json.extract! payment, :id, :amount, :payment_date, :payment_mode, :reference_number, :payment_type, :payment_number
end

json.first_payment do
  first_payment = accounting_invoice.accounting_payments.order(created_at: :asc).first
  if first_payment
    json.extract! first_payment, :amount, :payment_date, :payment_mode, :reference_number, :payment_type, :payment_number
  else
    json.nil!
  end
end

json.journal_entry_id accounting_invoice.journal_entry_id
