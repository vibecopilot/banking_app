class AddRestaurantTypeToFoodAndBeverage < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :restauranttype, :string
  end
end
