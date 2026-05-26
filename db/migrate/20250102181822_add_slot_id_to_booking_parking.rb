class AddSlotIdToBookingParking < ActiveRecord::Migration[5.1]
  def change
    add_column :booking_parkings, :slot_id, :integer
    
  end
end
