class AddCamBillIdToInvoiceReciept < ActiveRecord::Migration[5.1]
  def change
    add_column :invoice_receipts, :cam_bill_id, :integer
  end
end
