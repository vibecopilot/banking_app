class AddPrimeColumnToAmenityBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :amenity_bookings, :is_prime_booking, :boolean
  end
end
