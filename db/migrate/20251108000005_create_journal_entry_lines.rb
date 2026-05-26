class CreateJournalEntryLines < ActiveRecord::Migration[5.1]
   def change
     create_table :journal_entry_lines do |t|
       t.integer :journal_entry_id, null: false
       t.integer :ledger_id, null: false
       t.string :entry_side, null: false # 'debit' or 'credit'
       t.decimal :amount, precision: 15, scale: 2, null: false
       t.text :description
       t.integer :unit_id # Optional: for tracking which unit this line relates to

       t.timestamps
     end

     add_index :journal_entry_lines, :journal_entry_id
     add_index :journal_entry_lines, :ledger_id
     add_index :journal_entry_lines, :unit_id
     add_index :journal_entry_lines, :entry_side
   end
end
