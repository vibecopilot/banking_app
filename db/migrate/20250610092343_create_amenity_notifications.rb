class CreateAmenityNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :amenity_notifications do |t|
      t.integer :user_id
      t.integer :amenity_booking_id
      t.string :message
      t.string :read

      t.timestamps
    end
  end
end
