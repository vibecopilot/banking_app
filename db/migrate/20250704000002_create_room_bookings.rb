class CreateRoomBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :room_bookings do |t|
      t.references :room, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true
      t.references :site, null: false, foreign_key: true
      t.string :booking_reference, null: false
      t.date :check_in_date, null: false
      t.date :check_out_date, null: false
      t.integer :number_of_nights, null: false
      t.integer :adults_count, default: 1
      t.integer :children_count, default: 0
      t.decimal :room_rate_per_night, precision: 10, scale: 2, null: false
      t.decimal :total_room_charges, precision: 10, scale: 2, null: false
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0.0
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :status, default: 'pending'
      t.text :special_requests
      t.text :guest_details
      t.string :contact_phone
      t.string :contact_email
      t.datetime :booking_date
      t.datetime :confirmed_at
      t.datetime :cancelled_at
      t.text :cancellation_reason
      t.text :notes
      t.timestamps
    end

    add_index :room_bookings, [:site_id, :status]
    add_index :room_bookings, [:room_id, :check_in_date, :check_out_date], name: "idx_room_bookings_room_and_dates"
    add_index :room_bookings, :booking_reference, unique: true
    add_index :room_bookings, [:user_id, :status]
    add_index :room_bookings, [:check_in_date, :check_out_date]
  end
end
