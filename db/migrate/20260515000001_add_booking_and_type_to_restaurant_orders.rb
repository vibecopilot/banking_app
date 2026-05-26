class AddBookingAndTypeToRestaurantOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_orders, :booking_id, :integer
    add_column :restaurant_orders, :order_type, :string, default: "dine-in"
    add_column :restaurant_orders, :customer_name, :string
    add_column :restaurant_orders, :customer_phone, :string
    add_column :restaurant_orders, :customer_address, :text
    add_column :restaurant_orders, :service_charge, :float, default: 0.0
    add_column :restaurant_orders, :tax_amount, :float, default: 0.0
    add_column :restaurant_orders, :discount, :float, default: 0.0
    add_column :restaurant_orders, :paid_amount, :float, default: 0.0
    add_column :restaurant_orders, :payment_mode, :string
    add_column :restaurant_orders, :billed_at, :datetime
    add_column :restaurant_orders, :completed_at, :datetime
    add_index :restaurant_orders, :booking_id
    add_index :restaurant_orders, :order_type
  end
end
