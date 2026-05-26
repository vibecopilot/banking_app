class CreateAminitySetups < ActiveRecord::Migration[5.1]
  def change
    create_table :aminity_setups do |t|
      t.integer :aminity_id
      t.string :name
      t.integer :site_id
      t.integer :unit_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :slot_frequency

      t.timestamps
    end
  end
end
