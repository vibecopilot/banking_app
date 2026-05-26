class CreateHotels < ActiveRecord::Migration[5.1]
  def change
    create_table :hotels do |t|
      t.string :hotel_name
      t.string :location
      t.integer :site_id
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :is_available

      t.timestamps
    end
  end
end
