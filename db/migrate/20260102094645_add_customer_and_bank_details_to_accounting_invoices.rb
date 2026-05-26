class AddCustomerAndBankDetailsToAccountingInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :accounting_invoices, :customer_name, :string
    add_column :accounting_invoices, :customer_email, :string
    add_column :accounting_invoices, :customer_address, :text
    add_column :accounting_invoices, :bank_account, :string
    add_column :accounting_invoices, :bank_ifsc, :string
    add_column :accounting_invoices, :bank_aic, :string
    add_column :accounting_invoices, :gst_reverse_charge, :string
    add_column :accounting_invoices, :place_of_supply, :string
    add_column :accounting_invoices, :state, :string
    add_column :accounting_invoices, :state_code, :string
  end
end
