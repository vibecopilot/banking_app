class CreateRoomAvailability < ActiveRecord::Migration[5.1]
  def change
    create_table :room_availabilities do |t|
      t.references :room, null: false, foreign_key: true
      t.date :date, null: false
      t.boolean :is_available, default: true
      t.string :unavailable_reason
      t.decimal :special_price, precision: 10, scale: 2
      t.text :notes
      t.timestamps
    end

    add_index :room_availabilities, [:room_id, :date], unique: true
    add_index :room_availabilities, [:date, :is_available]
  end
end
