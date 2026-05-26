class CreatePrimeTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :prime_times do |t|
      t.references :amenity_booking_rules, foreign_key: true
      t.time :start_time
      t.time :end_time
      
      t.timestamps
    end
  end
end
