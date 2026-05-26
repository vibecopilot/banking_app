class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.integer :attendance_of_id
      t.string :attendance_of_type
      t.integer :resource_id
      t.string :resource_type
      t.datetime :punched_in_at
      t.datetime :punched_out_at
      t.text :work_log

      t.timestamps
    end
  end
end
