class AddOnlinePaymentAllowedToInvoiceSetups < ActiveRecord::Migration[5.1]
  def change
    add_column :invoice_setups, :online_payment_allowed, :boolean
  end
end
