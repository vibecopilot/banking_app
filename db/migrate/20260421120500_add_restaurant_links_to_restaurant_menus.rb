class AddRestaurantLinksToRestaurantMenus < ActiveRecord::Migration[5.2]
  def change
    change_table :restaurant_menus do |t|
      t.string  :category_name           # denormalised label (e.g. "North Indian")
      t.boolean :selected, default: true # checkbox state in F&B menu setup
    end
    add_index :restaurant_menus, :restaurant_id unless index_exists?(:restaurant_menus, :restaurant_id)
  end
end
