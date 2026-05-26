class AddNewCollumnToParkingSlot < ActiveRecord::Migration[5.1]
  def change
    add_column :parking_slots, :slot_prefix, :string
    add_column :parking_slots, :alphanumeric, :boolean
    add_column :parking_slots, :no_of_slots, :string
    add_column :parking_slots, :ev_charging_available, :boolean
    add_column :parking_slots, :total_ev_points, :integer
    add_reference :parking_slots, :parking_configurations, foreign_key: true
  end
end
