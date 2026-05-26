class AddRazorpayToRestaurantOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_orders, :razorpay_order_id, :string
    add_column :restaurant_orders, :razorpay_payment_id, :string
    add_column :restaurant_orders, :paid_at, :datetime
    add_column :restaurant_orders, :payment_failure_reason, :text
    add_column :restaurant_orders, :refund_amount, :decimal, precision: 12, scale: 2
    add_column :restaurant_orders, :refunded_at, :datetime
  end
end
