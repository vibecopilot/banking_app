json.extract! ledger, :id, :name, :code, :description, :opening_balance, :advance_amount, :current_balance, :ledger_type, :active, :is_system, :created_at, :updated_at

json.account_group do
  if ledger.account_group
    json.extract! ledger.account_group, :id, :name, :code, :group_type
  end
end

json.site do
  if ledger.site
    json.extract! ledger.site, :id, :name
  end
end

json.unit do
  if ledger.unit
    json.extract! ledger.unit, :id, :name
    json.building_name ledger.unit.building&.name
    json.floor_name ledger.unit.floor&.name
  else
    json.nil!
  end
end

json.full_name ledger.full_name
json.debit_nature ledger.debit_nature?
json.credit_nature ledger.credit_nature?
