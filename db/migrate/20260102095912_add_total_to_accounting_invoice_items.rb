class AddTotalToAccountingInvoiceItems < ActiveRecord::Migration[5.1]
  def change
    add_column :accounting_invoice_items, :total, :decimal, precision: 15, scale: 2
  end
end
