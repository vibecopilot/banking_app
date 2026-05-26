class CreateLedgers < ActiveRecord::Migration[5.1]
  def change
    create_table :ledgers do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :account_group_id, null: false
      t.integer :site_id, null: false
      t.integer :unit_id
      t.text :description
      t.decimal :opening_balance, precision: 15, scale: 2, default: 0.0
      t.decimal :current_balance, precision: 15, scale: 2, default: 0.0
      t.string :ledger_type
      t.boolean :active, default: true
      t.boolean :is_system, default: false

      t.timestamps
    end

    add_index :ledgers, :site_id
    add_index :ledgers, :account_group_id
    add_index :ledgers, :unit_id
    add_index :ledgers, [:code, :site_id], unique: true
  end
end
