json.extract! journal_entry, :id, :entry_number, :entry_date, :expense_month, :expense_year, :entry_type, :narration, :total_debit, :total_credit, :invoice_date, :invoice_number, :status, :posted_at, :created_at, :updated_at

json.site do
  if journal_entry.site
    json.extract! journal_entry.site, :id, :name
  end
end

json.unit do
  if journal_entry.unit
    json.extract! journal_entry.unit, :id, :name
    json.building_name journal_entry.unit.building&.name
    json.floor_name journal_entry.unit.floor&.name
  else
    json.nil!
  end
end

json.created_by do
  if journal_entry.created_by
    json.extract! journal_entry.created_by, :id, :firstname, :lastname, :email
  end
end

json.posted_by do
  if journal_entry.posted_by
    json.extract! journal_entry.posted_by, :id, :firstname, :lastname, :email
  else
    json.nil!
  end
end

json.balanced journal_entry.balanced?

json.journal_entry_lines journal_entry.journal_entry_lines do |line|
  json.extract! line, :id, :entry_side, :amount, :description
  json.ledger do
    json.extract! line.ledger, :id, :name, :code
    json.account_group_name line.ledger.account_group.name
  end
  if line.unit
    json.unit do
      json.extract! line.unit, :id, :name
    end
  end
end
