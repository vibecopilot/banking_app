class AddCreatedByIdToTableBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :table_bookings, :created_by_id, :integer
    add_column :restaurant_orders, :created_by_id, :integer
  end
end
