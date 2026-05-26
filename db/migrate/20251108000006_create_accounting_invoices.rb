class CreateAccountingInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :accounting_invoices do |t|
      t.string :invoice_number, null: false
      t.date :invoice_date, null: false
      t.date :due_date
      t.integer :site_id, null: false
      t.integer :unit_id
      t.integer :user_id
      t.integer :vendor_id
      t.string :invoice_type
      t.decimal :subtotal, precision: 15, scale: 2, default: 0.0
      t.decimal :tax_amount, precision: 15, scale: 2, default: 0.0
      t.decimal :total_amount, precision: 15, scale: 2, default: 0.0
      t.decimal :paid_amount, precision: 15, scale: 2, default: 0.0
      t.decimal :balance_amount, precision: 15, scale: 2, default: 0.0
      t.string :status, default: 'draft'
      t.text :notes
      t.text :terms_and_conditions
      t.integer :journal_entry_id
      t.integer :created_by_id
      t.datetime :sent_at
      t.datetime :paid_at

      t.timestamps
    end

    add_index :accounting_invoices, :site_id
    add_index :accounting_invoices, :unit_id
    add_index :accounting_invoices, :user_id
    add_index :accounting_invoices, :vendor_id
    add_index :accounting_invoices, :invoice_number, unique: true
    add_index :accounting_invoices, :invoice_date
    add_index :accounting_invoices, :due_date
    add_index :accounting_invoices, :status
    add_index :accounting_invoices, :journal_entry_id
  end
end
