class ChangeCuisinesToBeArrayInFoodAndBeverage < ActiveRecord::Migration[5.1]
  def change
        change_column :food_and_beverages, :cuisines, :text #, array: true, default: []
  end
end
