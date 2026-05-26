class AddIsHOtelColumnToAmenityBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :amenity_bookings, :is_book_hotel, :boolean
  end
end
