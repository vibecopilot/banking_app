class ChangeFixedStateToBeStringInStatusRestaurant < ActiveRecord::Migration[5.1]
  def up
    change_column :status_restaurants, :fixed_state, :string
  end

  def down
    change_column :status_restaurants, :fixed_state, :boolean # Replace with the previous data type (e.g., :integer)
  end
end
