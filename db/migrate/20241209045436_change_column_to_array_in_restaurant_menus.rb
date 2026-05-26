class ChangeColumnToArrayInRestaurantMenus < ActiveRecord::Migration[5.1]
  def change
    change_column :status_restaurants, :fixed_state, :integer, array: true, default: [], using: 'ARRAY[fixed_state]'
  end
end
