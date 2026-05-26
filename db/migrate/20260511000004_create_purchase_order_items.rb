class CreatePurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_items do |t|
      t.integer :purchase_order_id
      t.integer :ingredient_id
      t.decimal :quantity, precision: 12, scale: 3, default: 0.0
      t.decimal :unit_price, precision: 10, scale: 2, default: 0.0
      t.decimal :total_price, precision: 12, scale: 2, default: 0.0
      t.timestamps
    end
    add_index :purchase_order_items, :purchase_order_id
    add_index :purchase_order_items, :ingredient_id
  end
end
