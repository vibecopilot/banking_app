class AddRestaurantTableIdToTableBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :table_bookings, :restaurant_table_id, :integer
    add_column :table_bookings, :contact_number, :string
    add_column :table_bookings, :customer_name, :string
    add_column :table_bookings, :notes, :text
    add_index :table_bookings, :restaurant_table_id
    add_index :table_bookings, :restaurant_id
  end
end
