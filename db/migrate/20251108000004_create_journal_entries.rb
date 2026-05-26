class CreateJournalEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :journal_entries do |t|
      t.string :entry_number, null: false
      t.date :entry_date, null: false
      t.string :entry_type
      t.text :description
      t.string :status, default: 'draft'
      t.decimal :total_debit, precision: 15, scale: 2, default: 0.0
      t.decimal :total_credit, precision: 15, scale: 2, default: 0.0
      t.integer :site_id, null: false
      t.integer :unit_id
      t.integer :created_by_id
      t.integer :posted_by_id
      t.datetime :posted_at
      t.string :reference_type
      t.integer :reference_id

      t.timestamps
    end

    add_index :journal_entries, :site_id
    add_index :journal_entries, :unit_id
    add_index :journal_entries, :entry_number
    add_index :journal_entries, :entry_date
    add_index :journal_entries, :status
    add_index :journal_entries, [:reference_type, :reference_id]
  end
end
