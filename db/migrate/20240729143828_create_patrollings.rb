class CreatePatrollings < ActiveRecord::Migration[5.1]
  def change
    create_table :patrollings do |t|
      t.integer :building_id
      t.date :start_date
      t.date :end_date
      t.time :start_time
      t.time :end_time
      t.integer :time_intervals

      t.timestamps
    end
  end
end
