class AllowNullDescriptionOnAccountingInvoiceItems < ActiveRecord::Migration[5.1]
  def change
    change_column :accounting_invoice_items, :description, :string, null: true, default: nil
  end
end
