json.ledger do
  json.partial! 'ledgers/ledger', ledger: @ledger
end

json.opening_balance @opening_balance
json.closing_balance @closing_balance

json.transactions @transactions do |line|
  json.id line.id
  json.date line.journal_entry.entry_date
  json.entry_number line.journal_entry.entry_number
  json.narration line.journal_entry.narration
  json.description line.description
  json.entry_side line.entry_side
  json.amount line.amount
  json.debit line.debit? ? line.amount : 0
  json.credit line.credit? ? line.amount : 0
end
