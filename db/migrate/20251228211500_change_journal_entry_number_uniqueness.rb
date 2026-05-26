class ChangeJournalEntryNumberUniqueness < ActiveRecord::Migration[5.1]
  def change
    remove_index :journal_entries, :entry_number
    add_index :journal_entries, [:site_id, :entry_number], unique: true
  end
end
