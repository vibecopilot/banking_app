class RenameAdvanceMinToAdvanceBooking < ActiveRecord::Migration[5.1]
  def change
    rename_column :amenities, :advance_min, :advance_booking
  end
end
