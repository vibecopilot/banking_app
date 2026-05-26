class AddMaxBookingsPerWeekToAminitySetups < ActiveRecord::Migration[5.1]
  def change
    add_column :aminity_setups, :max_bookings_per_week, :integer, default: nil
  end
end
