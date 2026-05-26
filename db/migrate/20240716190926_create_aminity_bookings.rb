class CreateAminityBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :aminity_bookings do |t|
      t.date :date
      t.integer :aminity_id
      t.text :comment
      t.text :cancellation_policy
      t.text :terms_and_conditions
      t.string :payment_method
      t.integer :user_id
      t.string :status
      t.integer :created_by_id

      t.timestamps
    end
  end
end
