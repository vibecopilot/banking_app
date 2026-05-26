class AddMasterPriceToRestaurantMenu < ActiveRecord::Migration[5.1]
  def change
    add_column :restaurant_menus, :master_price, :integer
  end
end
