class AddNewColumnToAccountingInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :accounting_invoices, :amount, :integer
    add_column :accounting_invoices, :payment_mode, :string
    add_column :accounting_invoices, :payment_ref_no, :string
    add_column :accounting_invoices, :source_type, :string
  end
end
