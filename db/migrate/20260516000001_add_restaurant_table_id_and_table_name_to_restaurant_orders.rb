class AddRestaurantTableIdAndTableNameToRestaurantOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_orders, :restaurant_table_id, :integer
    add_column :restaurant_orders, :table_name, :string
    add_index :restaurant_orders, :restaurant_table_id
  end
end
