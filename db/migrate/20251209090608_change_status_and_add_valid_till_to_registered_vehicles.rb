class ChangeStatusAndAddValidTillToRegisteredVehicles < ActiveRecord::Migration[5.1]
  def change
    change_column :registered_vehicles, :status, :boolean, default: true

    add_column :registered_vehicles, :valid_till, :datetime
  end
end
