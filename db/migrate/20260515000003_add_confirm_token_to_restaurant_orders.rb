class AddConfirmTokenToRestaurantOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :restaurant_orders, :confirm_token, :string
    add_index :restaurant_orders, :confirm_token, unique: true
    add_column :restaurant_orders, :confirmed_at, :datetime
  end
end
