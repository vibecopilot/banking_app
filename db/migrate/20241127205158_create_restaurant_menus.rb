  class CreateRestaurantMenus < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurant_menus do |t|
      t.integer :restaurant_id
      t.string :name
      t.string :sku
      t.float :price
      t.boolean :active
      t.integer :category_id
      t.integer :sub_category_id
      t.text :description

      t.timestamps
    end
  end
end
