class AddConvenienceFeeToFoodAndBeverages < ActiveRecord::Migration[5.2]
  def change
    add_column :food_and_beverages, :convenience_fee, :float
  end
end
