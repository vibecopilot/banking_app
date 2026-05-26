class CreateRegisteredVehicleVisits < ActiveRecord::Migration[5.1]
  def change
    create_table :registered_vehicle_visits do |t|
      t.references :registered_vehicle, foreign_key: true
      t.datetime :check_in
      t.datetime :check_out
      t.integer :site_id
      t.integer :created_by_id

      t.timestamps
    end
  end
end
