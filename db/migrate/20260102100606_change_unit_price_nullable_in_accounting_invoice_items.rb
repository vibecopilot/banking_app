class ChangeUnitPriceNullableInAccountingInvoiceItems < ActiveRecord::Migration[5.1]
  def change
    change_column_null :accounting_invoice_items, :unit_price, true
    change_column_default :accounting_invoice_items, :unit_price, from: nil, to: 0
  end
end
