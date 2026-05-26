class CreateSeatBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :seat_bookings do |t|
      t.string :book_type
      t.integer :user_id
      t.date :booking_date
      t.integer :building_id
      t.integer :floor_id
      t.boolean :booking_status
      t.integer :created_by_id

      t.timestamps
    end
  end
end
