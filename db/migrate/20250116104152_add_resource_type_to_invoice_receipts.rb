class AddResourceTypeToInvoiceReceipts < ActiveRecord::Migration[5.1]
  def change
    add_column :invoice_receipts, :resource_type, :string
    add_column :invoice_receipts, :resource_id, :integer
  end
end
