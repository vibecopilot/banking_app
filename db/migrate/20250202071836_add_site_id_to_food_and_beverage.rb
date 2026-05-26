class AddSiteIdToFoodAndBeverage < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :site_id, :integer
  end
end
