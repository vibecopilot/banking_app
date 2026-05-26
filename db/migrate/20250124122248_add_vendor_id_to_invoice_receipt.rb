class AddVendorIdToInvoiceReceipt < ActiveRecord::Migration[5.1]
  def change
    add_column :invoice_receipts, :vendor_id, :integer
  end
end
