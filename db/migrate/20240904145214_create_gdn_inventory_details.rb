class CreateGdnInventoryDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :gdn_inventory_details do |t|
      t.integer :inventory
      t.integer :current_stock
      t.integer :quantity
      t.text :comments
      t.integer :gdn_id

      t.timestamps
    end
  end
end
