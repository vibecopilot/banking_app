class CreateMeterReadings < ActiveRecord::Migration[5.1]
  def change
    create_table :meter_readings do |t|
      t.integer :meter_id
      t.decimal :opening
      t.decimal :closing
      t.decimal :consumption
      t.string :parameter

      t.timestamps
    end
  end
end
