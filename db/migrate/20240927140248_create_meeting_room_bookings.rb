class CreateMeetingRoomBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :meeting_room_bookings do |t|
      t.string :book_type
      t.integer :user_id
      t.date :booking_date
      t.string :facility_type
      t.string :payment_mode
      t.string :upi
      t.text :comment
      t.boolean :booking_status
      t.integer :created_by_id

      t.timestamps
    end
  end
end
