class AddFieldsToAmenityBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :amenity_bookings, :amount, :float
    add_column :amenity_bookings, :member_adult, :integer
    add_column :amenity_bookings, :member_child, :integer
    add_column :amenity_bookings, :guest_adult, :integer
    add_column :amenity_bookings, :guest_child, :integer
  end
end
