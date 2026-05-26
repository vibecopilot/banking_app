class CreateBookingParkings < ActiveRecord::Migration[5.1]
  def change
    create_table :booking_parkings do |t|
      t.integer :parking_id
      t.date :booking_date
      t.datetime :booking_start_time
      t.datetime :booking_end_time
      t.integer :user_id
      t.integer :site_id
      t.boolean :status

      t.timestamps
    end
  end
end
