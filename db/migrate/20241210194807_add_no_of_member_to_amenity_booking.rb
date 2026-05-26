class AddNoOfMemberToAmenityBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :amenity_bookings, :no_of_members, :integer
    add_column :amenity_bookings, :no_of_guests, :integer
  end
end
