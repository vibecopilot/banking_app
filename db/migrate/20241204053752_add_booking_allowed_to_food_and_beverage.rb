class AddBookingAllowedToFoodAndBeverage < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :booking_allowed, :boolean
    add_column :food_and_beverages, :order_allowed, :boolean
  end
end
