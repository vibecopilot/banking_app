class AddDeliveryChargesAndConvenienceFeeToRestaurantOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_orders, :delivery_charges, :float
    add_column :restaurant_orders, :convenience_fee, :float
  end
end
