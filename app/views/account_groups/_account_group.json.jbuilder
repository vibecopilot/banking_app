json.extract! account_group, :id, :name, :code, :group_type, :description, :active, :is_system, :parent_id, :created_at, :updated_at

json.parent do
  if account_group.parent
    json.extract! account_group.parent, :id, :name, :code
  else
    json.nil!
  end
end

json.full_name account_group.full_name
json.debit_nature account_group.debit_nature?
json.credit_nature account_group.credit_nature?

if defined?(@include_children) && @include_children
  json.children account_group.children do |child|
    json.extract! child, :id, :name, :code, :group_type, :active
  end
end

if defined?(@include_ledgers) && @include_ledgers
  json.ledgers_count account_group.ledgers.count
end
