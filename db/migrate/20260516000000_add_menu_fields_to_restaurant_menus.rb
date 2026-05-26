class AddMenuFieldsToRestaurantMenus < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_menus, :prep_time, :integer, default: 15
    add_column :restaurant_menus, :spice_level, :string, default: "Medium"
    add_column :restaurant_menus, :is_favorite, :boolean, default: false
  end
end
