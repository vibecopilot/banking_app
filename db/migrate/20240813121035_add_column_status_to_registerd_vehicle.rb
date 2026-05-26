class AddColumnStatusToRegisterdVehicle < ActiveRecord::Migration[5.1]
  def change
    add_column :registered_vehicles, :status, :boolean, default: false
  end
end
