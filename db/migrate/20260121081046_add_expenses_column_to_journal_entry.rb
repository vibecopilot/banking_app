class AddExpensesColumnToJournalEntry < ActiveRecord::Migration[5.1]
  def change
    add_column :journal_entries, :expense_month, :integer
    add_column :journal_entries, :expense_year, :integer
  end
end
