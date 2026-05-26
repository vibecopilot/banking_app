class CreateVisitorDeviceLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :visitor_device_logs do |t|
      t.string :employee_no
      t.string :name
      t.datetime :in_time
      t.datetime :out_time
      t.integer :door_no
      t.integer :device_serial_no
      t.timestamps
    end
    add_index :visitor_device_logs, [:employee_no, :in_time, :out_time], unique: true, name: 'index_unique_visitor_logs'
  end
end
