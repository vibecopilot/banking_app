class AddStatusToAmenityBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :amenity_bookings, :status, :string
    add_column :amenity_bookings, :payment_mode, :string
    add_column :comments, :resource_id, :integer
    add_column :comments, :resource_type, :string
    add_column :comments, :rating, :integer
    add_column :comments, :comment, :string
  end
end
