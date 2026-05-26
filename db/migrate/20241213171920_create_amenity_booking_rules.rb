class CreateAmenityBookingRules < ActiveRecord::Migration[5.1]
  def change
    create_table :amenity_booking_rules do |t|
      t.integer :enumerator
      t.integer :duration
      t.string :level
      t.boolean :active
      t.integer :amenity_id
      t.integer :site_id

      t.timestamps
    end
  end
end
