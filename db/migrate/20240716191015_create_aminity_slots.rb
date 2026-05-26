class CreateAminitySlots < ActiveRecord::Migration[5.1]
  def change
    create_table :aminity_slots do |t|
      t.integer :aminity_id
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
