class AddSomefieldToFoodAndBeverages < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :table_booking_start_date, :date
    add_column :food_and_beverages, :table_booking_end_date, :date
    add_column :food_and_beverages, :table_booking_start_time, :time
    add_column :food_and_beverages, :table_booking_end_time, :time
    add_column :food_and_beverages, :booking_capacity, :integer
    add_column :food_and_beverages, :waiting_capacity, :integer
    add_column :food_and_beverages, :booking_not_available_text, :string
    add_column :food_and_beverages, :food_and_beverages_availability, :text
  end
end
