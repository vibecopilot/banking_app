class AddUnitNoToAccountingInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :accounting_invoices, :unit_no, :string
  end
end
