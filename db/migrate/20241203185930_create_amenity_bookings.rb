class CreateAmenityBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :amenity_bookings do |t|
      t.integer :amenity_id
      t.integer :amenity_slot_id
      t.integer :user_id
      t.date :booking_date
      t.integer :site_id

      t.timestamps
    end
  end
end
