class CreateVehicleSetups < ActiveRecord::Migration[5.1]
  def change
    create_table :vehicle_setups do |t|
      t.string :vehicle_category
      t.string :vehicle_type_name
      t.string :status

      t.timestamps
    end
  end
end
