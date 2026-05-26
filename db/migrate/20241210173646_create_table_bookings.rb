class CreateTableBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :table_bookings do |t|
      t.integer :restaurant_id
      t.date :ondate
      t.time :ontime
      t.integer :user_id
      t.integer :no_of_person
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
