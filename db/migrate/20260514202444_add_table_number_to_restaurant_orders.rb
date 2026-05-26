class AddTableNumberToRestaurantOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_orders, :table_number, :string
  end
end
