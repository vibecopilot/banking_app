class AddTotalValueAndTotalToCamBillCharges < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bill_charges, :total_value, :decimal
    add_column :cam_bill_charges, :total, :decimal
    add_column :cam_bill_charges, :discount_amount, :decimal
  end
end
