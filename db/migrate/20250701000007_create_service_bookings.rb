class CreateServiceBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :service_bookings do |t|
      t.date :booking_date, null: false
      t.string :status, default: 'pending' # pending, confirmed, in_progress, completed, cancelled
      t.text :special_instructions
      t.text :cancellation_reason
      t.datetime :cancelled_at
      t.decimal :total_amount, precision: 10, scale: 2
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :final_amount, precision: 10, scale: 2
      t.string :payment_status, default: 'pending' # pending, paid, failed, refunded
      t.string :payment_method # cash, online, card
      t.string :transaction_id
      t.datetime :service_started_at
      t.datetime :service_completed_at
      t.integer :rating # 1-5 stars
      t.text :feedback
      t.references :user, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.references :service_subcategory, null: false, foreign_key: true
      t.references :service_slot, null: false, foreign_key: true
      t.references :service_pricing, null: false, foreign_key: true

      t.timestamps
    end

    # add_index :service_bookings, [:user_id, :booking_date]
    # add_index :service_bookings, [:service_subcategory_id, :booking_date]
    # add_index :service_bookings, [:service_slot_id, :booking_date]
    # add_index :service_bookings, :status
  end
end
