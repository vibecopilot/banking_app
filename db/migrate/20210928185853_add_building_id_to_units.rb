class AddBuildingIdToUnits < ActiveRecord::Migration[5.1]
  def change
    add_column :units, :building_id, :integer
    add_column :units, :floor_id, :integer
  end
end
