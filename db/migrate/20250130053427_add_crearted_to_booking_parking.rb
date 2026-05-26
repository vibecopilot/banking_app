class AddCreartedToBookingParking < ActiveRecord::Migration[5.1]
  def change
    add_column :booking_parkings, :created_by_id, :integer
  end
end
