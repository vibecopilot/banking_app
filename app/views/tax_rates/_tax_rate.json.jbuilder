json.extract! tax_rate, :id, :name, :tax_type, :rate, :description, :active, :effective_from, :effective_to, :created_at, :updated_at

json.ledger do
  if tax_rate.ledger
    json.extract! tax_rate.ledger, :id, :name, :code
  else
    json.nil!
  end
end

json.display_name tax_rate.display_name
json.effective tax_rate.effective?
