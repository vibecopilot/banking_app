class CreateTaxRates < ActiveRecord::Migration[5.1]
  def change
    create_table :tax_rates do |t|
      t.string :name, null: false
      t.string :tax_type, null: false
      t.decimal :rate, precision: 5, scale: 2, null: false
      t.integer :site_id
      t.integer :ledger_id
      t.text :description
      t.boolean :active, default: true
      t.date :effective_from
      t.date :effective_to

      t.timestamps
    end

    add_index :tax_rates, :site_id
    add_index :tax_rates, :ledger_id
    add_index :tax_rates, :tax_type
    add_index :tax_rates, :active
  end
end
