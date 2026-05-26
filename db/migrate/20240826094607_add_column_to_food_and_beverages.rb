class AddColumnToFoodAndBeverages < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :restaurant_schedule, :json
  end
end
