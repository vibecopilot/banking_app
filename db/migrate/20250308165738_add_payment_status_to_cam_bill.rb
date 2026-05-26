class AddPaymentStatusToCamBill < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bills, :payment_status, :string
  end
end
