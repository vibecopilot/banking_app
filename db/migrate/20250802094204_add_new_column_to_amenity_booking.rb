class AddNewColumnToAmenityBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :amenity_bookings, :checkin_at, :datetime
    add_column :amenity_bookings, :checkout_at, :datetime
  end
end
