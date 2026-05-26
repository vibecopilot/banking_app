class AddBuildingIdToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :building_id, :integer
    add_index :categories, :building_id
  end
end
