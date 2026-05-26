class CreateRestaurantFloors < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurant_floors do |t|
      t.integer :food_and_beverage_id, null: false
      t.string  :name, null: false
      t.timestamps
    end
    add_index :restaurant_floors, :food_and_beverage_id
  end
end
