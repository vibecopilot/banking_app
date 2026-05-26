json.extract! accounting_payment, :id, :payment_number, :payment_date, :payment_type, :payment_mode, 
                :amount, :reference_number, :notes, :created_at, :updated_at

json.site do
  if accounting_payment.site
    json.extract! accounting_payment.site, :id, :name
  end
end

json.unit do
  if accounting_payment.unit
    json.extract! accounting_payment.unit, :id, :name
    json.building_name accounting_payment.unit.building&.name
    json.floor_name accounting_payment.unit.floor&.name
  else
    json.nil!
  end
end

json.accounting_invoice do
  if accounting_payment.accounting_invoice
    json.extract! accounting_payment.accounting_invoice, :id, :invoice_number, :invoice_date, :total_amount, :status
  else
    json.nil!
  end
end

json.user do
  if accounting_payment.user
    json.extract! accounting_payment.user, :id, :firstname, :lastname, :email, :mobile
  else
    json.nil!
  end
end

json.vendor do
  if accounting_payment.vendor
    json.extract! accounting_payment.vendor, :id, :vendor_name
  else
    json.nil!
  end
end

json.received_by do
  if accounting_payment.received_by
    json.extract! accounting_payment.received_by, :id, :firstname, :lastname
  else
    json.nil!
  end
end

json.created_by do
  if accounting_payment.created_by
    json.extract! accounting_payment.created_by, :id, :firstname, :lastname
  end
end

json.journal_entry_id accounting_payment.journal_entry_id
