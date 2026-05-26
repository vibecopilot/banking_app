class CreateVehicleDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :vehicle_details do |t|
      t.integer :user_id
      t.string :vehicle_type
      t.string :vehicle_no
      t.string :parking_slot_no

      t.timestamps
    end
    
    add_index :vehicle_details, :user_id
  end
end
