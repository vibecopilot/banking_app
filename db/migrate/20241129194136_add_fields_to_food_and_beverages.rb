class AddFieldsToFoodAndBeverages < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :table_number, :integer
  end
end
