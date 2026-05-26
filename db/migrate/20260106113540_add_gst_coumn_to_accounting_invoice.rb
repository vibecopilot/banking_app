class AddGstCoumnToAccountingInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :accounting_invoices, :gst_no, :string
  end
end
