class AddSiteColumnToSeatBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :seat_bookings, :site_id, :integer
  end
end
