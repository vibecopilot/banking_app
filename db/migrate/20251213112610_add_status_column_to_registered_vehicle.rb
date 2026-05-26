class AddStatusColumnToRegisteredVehicle < ActiveRecord::Migration[5.1]
  def change
    add_column :registered_vehicles, :approved, :string, default: "Pending"
    add_column :registered_vehicles, :vehicle_in_out, :string
    add_index :registered_vehicles, :vehicle_in_out
  end
end
