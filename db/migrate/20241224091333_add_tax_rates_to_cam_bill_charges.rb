class AddTaxRatesToCamBillCharges < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bill_charges, :cgst_rate, :decimal
    add_column :cam_bill_charges, :sgst_rate, :decimal
    add_column :cam_bill_charges, :igst_rate, :decimal
  end
end
