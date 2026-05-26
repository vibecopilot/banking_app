class CreateRestaurantOrderItems < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurant_order_items do |t|
      t.integer :order_id
      t.integer :restaurant_menu_id
      t.integer :quantity
      t.float :amount
      t.float :rate

      t.timestamps
    end
  end
end
