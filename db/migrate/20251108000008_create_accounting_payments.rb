class CreateAccountingPayments < ActiveRecord::Migration[5.1]
  def change
    create_table :accounting_payments do |t|
      t.string :payment_number, null: false
      t.date :payment_date, null: false
      t.integer :site_id, null: false
      t.integer :unit_id
      t.integer :accounting_invoice_id
      t.integer :user_id
      t.integer :vendor_id
      t.string :payment_type
      t.string :payment_mode
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :reference_number
      t.text :notes
      t.integer :journal_entry_id
      t.integer :received_by_id
      t.integer :created_by_id

      t.timestamps
    end

    add_index :accounting_payments, :site_id
    add_index :accounting_payments, :unit_id
    add_index :accounting_payments, :accounting_invoice_id
    add_index :accounting_payments, :user_id
    add_index :accounting_payments, :vendor_id
    add_index :accounting_payments, :payment_number, unique: true
    add_index :accounting_payments, :payment_date
    add_index :accounting_payments, :payment_type
    add_index :accounting_payments, :journal_entry_id
  end
end
