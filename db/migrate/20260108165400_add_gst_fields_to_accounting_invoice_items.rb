class AddGstFieldsToAccountingInvoiceItems < ActiveRecord::Migration[5.1]
  def change
    add_column :accounting_invoice_items, :gst_type, :string, default: 'cgst_sgst'
    add_column :accounting_invoices, :gst_input_value, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
