class CreateRestaurantOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurant_orders do |t|
      t.integer :restaurant_id
      t.date :ondate
      t.time :ontime
      t.integer :user_id
      t.string :payment_status
      t.float :total_amount
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
