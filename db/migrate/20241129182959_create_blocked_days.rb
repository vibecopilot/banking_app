class CreateBlockedDays < ActiveRecord::Migration[5.1]
  def change
    create_table :blocked_days do |t|
      t.integer :restaurant_id
      t.date :start_date
      t.date :start_date
      t.text :reason
      t.boolean :booking_allowed
      t.boolean :order_allowed

      t.timestamps
    end
  end
end
