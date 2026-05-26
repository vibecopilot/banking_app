class CreateInventoryDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :inventory_details do |t|
      t.integer :item_id
      t.integer :expected_quantity
      t.integer :received_quantity
      t.integer :approved_quantity
      t.integer :rejected_quantity
      t.float :rate
      t.float :csgt_rate
      t.float :csgt_amt
      t.float :sgst_rate
      t.float :sgst_amt
      t.float :igst_rate
      t.float :igst_amt
      t.float :tcs_rate
      t.float :tcs_amt
      t.float :tax_amt
      t.float :inventory_amount
      t.float :total_amount
      t.integer :grn_id

      t.timestamps
    end
  end
end
