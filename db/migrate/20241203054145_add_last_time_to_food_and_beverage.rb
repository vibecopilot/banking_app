class AddLastTimeToFoodAndBeverage < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :last_booking_time, :time
  end
end
