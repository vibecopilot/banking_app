class UpdateAccountingInvoiceItemsForGst < ActiveRecord::Migration[5.1]
  def change
    # Add new GST-specific fields
    add_column :accounting_invoice_items, :s_no, :integer
    add_column :accounting_invoice_items, :service_description, :string
    add_column :accounting_invoice_items, :service_details, :text
    add_column :accounting_invoice_items, :hsn_sac_code, :string
    add_column :accounting_invoice_items, :rate, :decimal, precision: 15, scale: 2
    add_column :accounting_invoice_items, :taxable_value, :decimal, precision: 15, scale: 2
    add_column :accounting_invoice_items, :cgst_rate, :decimal, precision: 5, scale: 2
    add_column :accounting_invoice_items, :cgst_amount, :decimal, precision: 15, scale: 2
    add_column :accounting_invoice_items, :sgst_rate, :decimal, precision: 5, scale: 2
    add_column :accounting_invoice_items, :sgst_amount, :decimal, precision: 15, scale: 2
    add_column :accounting_invoice_items, :igst_rate, :decimal, precision: 5, scale: 2
    add_column :accounting_invoice_items, :igst_amount, :decimal, precision: 15, scale: 2
  end
end
