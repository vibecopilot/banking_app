class CreateInvoiceReceipts < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_receipts do |t|
      t.string :receipt_number
      t.string :invoice_number
      t.integer :building_id
      t.integer :unit_id
      t.integer :address_id
      t.string :payment_mode
      t.decimal :amount_received
      t.string :transaction_or_cheque_number
      t.string :bank_name
      t.string :branch_name
      t.date :payment_date
      t.date :receipt_date
      t.text :notes

      t.timestamps
    end
  end
end
