class CreateRegisteredVehicles < ActiveRecord::Migration[5.1]
  def change
    create_table :registered_vehicles do |t|
      t.integer :slot_number
      t.string :vehicle_category
      t.string :vehicle_type
      t.string :sticker_number
      t.string :registration_number
      t.string :insurance_number
      t.date :insurance_valid_till
      t.string :category
      t.string :vehicle_number
      t.integer :unit_id
      t.integer :user_id
      t.integer :created_by_id

      t.timestamps
    end
  end
end
