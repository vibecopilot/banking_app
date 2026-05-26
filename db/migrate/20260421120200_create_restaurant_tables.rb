class CreateRestaurantTables < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurant_tables do |t|
      t.integer :food_and_beverage_id, null: false
      t.integer :restaurant_floor_id
      t.string  :name             # e.g. "Table 1"
      t.integer :capacity, default: 0
      t.timestamps
    end
    add_index :restaurant_tables, :food_and_beverage_id
    add_index :restaurant_tables, :restaurant_floor_id
  end
end
