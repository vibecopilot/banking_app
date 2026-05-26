class AddInvoiceColumnToJournalEntry < ActiveRecord::Migration[5.1]
  def change
    add_column :journal_entries, :invoice_number, :string
    add_column :journal_entries, :invoice_date, :datetime
  end
end
