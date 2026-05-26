class AddCategoryIdToMenus < ActiveRecord::Migration[5.2]
  def change
    add_column :menus, :category_id, :integer
  end
end
#.