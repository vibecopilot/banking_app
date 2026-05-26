class CreateLoiItems < ActiveRecord::Migration[5.1]
  def change
    create_table :loi_items do |t|
      t.integer :loi_detail_id
      t.integer :item_id
      t.string :sac_code
      t.integer :quantity
      t.integer :standard_unit_id
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
      t.float :amount
      t.float :total_amount

      t.timestamps
    end
  end
end
