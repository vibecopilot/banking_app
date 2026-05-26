class CreateInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :inventories do |t|
      t.string :name
      t.integer :inventory_type
      t.integer :criticality
      t.integer :asset_group_id
      t.integer :asset_sub_group_id
      t.integer :asset_id
      t.string :code
      t.string :serial_number
      t.float :quantity
      t.string :min_stock_level
      t.string :min_order_level
      t.float :cgst_rate
      t.float :sgst_rate
      t.float :igst_rate
      t.boolean :active
      t.integer :hsn_id
      t.datetime :expiry_date
      t.string :unit
      t.float :cost

      t.timestamps
    end
  end
end
