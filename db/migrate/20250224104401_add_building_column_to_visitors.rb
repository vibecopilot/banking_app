class AddBuildingColumnToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :building_id, :integer
    add_column :visitors, :unit_id, :integer
    add_column :visitors, :floor_id, :integer
  end
end
