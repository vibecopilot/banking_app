class CreateIncomeEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :income_entries do |t|
      t.references :site, foreign_key: true
      t.string :source_type
      t.integer :source_id
      t.decimal :amount
      t.string :invoice_number
      t.date :received_date
      t.string :payment_mode
      t.string :reference_number
      t.references :user, foreign_key: true
      t.references :unit, foreign_key: true
      t.references :journal_entry, foreign_key: true
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
