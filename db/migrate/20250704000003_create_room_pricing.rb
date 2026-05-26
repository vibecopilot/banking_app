class CreateRoomPricing < ActiveRecord::Migration[5.1]
  def change
    create_table :room_pricings do |t|
      t.references :room, null: false, foreign_key: true
      t.date :effective_date, null: false
      t.date :end_date
      t.decimal :price_per_night, precision: 10, scale: 2, null: false
      t.decimal :weekend_price, precision: 10, scale: 2
      t.decimal :holiday_price, precision: 10, scale: 2
      t.string :pricing_type, default: 'regular' # regular, weekend, holiday, special
      t.text :description
      t.boolean :is_active, default: true
      t.timestamps
    end

    add_index :room_pricings, [:room_id, :effective_date]
    add_index :room_pricings, [:room_id, :pricing_type]
  end
end
