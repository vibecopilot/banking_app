class CreateRestaurantCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurant_categories do |t|
      t.integer :food_and_beverage_id, null: false
      t.string  :name, null: false
      t.boolean :custom, default: false
      t.timestamps
    end
    add_index :restaurant_categories, :food_and_beverage_id
  end
end
