class CreateParkingConfigurations < ActiveRecord::Migration[5.1]
  def change
    create_table :parking_configurations do |t|
      t.string :name
      t.integer :building_id
      t.integer :floor_id
      t.string :vehicle_type

      t.timestamps
    end
  end
end
