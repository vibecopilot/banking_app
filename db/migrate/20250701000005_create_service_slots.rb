class CreateServiceSlots < ActiveRecord::Migration[5.1]
  def change
    create_table :service_slots do |t|
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :max_bookings, default: 1 # how many bookings can be made for this slot
      t.boolean :active, default: true
      t.references :service_subcategory, null: false, foreign_key: true

      t.timestamps
    end

    # add_index :service_slots, [:service_subcategory_id, :start_time], unique: true
  end
end
