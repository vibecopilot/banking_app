class AddDaysOfWeekToFoodAndBeverage < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :mon, :integer
    add_column :food_and_beverages, :tue, :integer
    add_column :food_and_beverages, :wed, :integer
    add_column :food_and_beverages, :thu, :integer
    add_column :food_and_beverages, :fri, :integer
    add_column :food_and_beverages, :sat, :integer
    add_column :food_and_beverages, :sun, :integer
    add_column :food_and_beverages, :break_start_time, :time
    add_column :food_and_beverages, :break_end_time, :time
  end
end
