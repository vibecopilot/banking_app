class CreateAmenityOperationalDays < ActiveRecord::Migration[5.2]
  def change
    create_table :amenity_operational_days do |t|
      t.references :amenity, foreign_key: true
      t.integer :day_of_week
      t.string :start_time
      t.string :end_time
      t.boolean :is_active

      t.timestamps
    end
  end
end
