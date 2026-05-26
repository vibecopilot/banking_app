class CreateRestaurantCuisines < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurant_cuisines do |t|
      t.integer :food_and_beverage_id, null: false
      t.string  :name, null: false
      t.boolean :custom, default: false
      t.timestamps
    end
    add_index :restaurant_cuisines, :food_and_beverage_id
  end
end
