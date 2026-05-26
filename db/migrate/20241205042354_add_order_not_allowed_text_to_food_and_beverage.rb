class AddOrderNotAllowedTextToFoodAndBeverage < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :order_not_allowed_text, :text
  end
end
