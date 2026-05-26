class AddInvoiceNumberToUnits < ActiveRecord::Migration[5.1]
  def change
    add_column :units, :invoice_number, :string
  end
end
