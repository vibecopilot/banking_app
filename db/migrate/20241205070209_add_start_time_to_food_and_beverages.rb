class AddStartTimeToFoodAndBeverages < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :start_time, :time
    add_column :food_and_beverages, :end_time, :time
  end
end
