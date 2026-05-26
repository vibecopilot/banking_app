class CreateCamBillCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :cam_bill_charges do |t|
      t.integer :charge_id
      t.float :charge_amount
      t.float :sub_amount
      t.float :cgst_amount
      t.float :igst_amount
      t.float :sgst_amount
      t.string :description
      t.integer :cam_bill_id

      t.timestamps
    end
  end
end
