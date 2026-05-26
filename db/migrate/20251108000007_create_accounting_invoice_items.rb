class CreateAccountingInvoiceItems < ActiveRecord::Migration[5.1]
  def change
    create_table :accounting_invoice_items do |t|
      t.integer :accounting_invoice_id, null: false
      t.string :description, null: false
      t.integer :ledger_id
      t.decimal :quantity, precision: 10, scale: 2, default: 1.0
      t.decimal :unit_price, precision: 15, scale: 2, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.integer :tax_rate_id
      t.decimal :tax_amount, precision: 15, scale: 2, default: 0.0
      t.decimal :total_amount, precision: 15, scale: 2, null: false
      t.string :item_type
      t.text :notes

      t.timestamps
    end

    add_index :accounting_invoice_items, :accounting_invoice_id
    add_index :accounting_invoice_items, :ledger_id
    add_index :accounting_invoice_items, :tax_rate_id
  end
end
