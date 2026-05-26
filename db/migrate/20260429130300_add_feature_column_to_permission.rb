class AddFeatureColumnToPermission < ActiveRecord::Migration[5.2]
  def change
    add_column :permissions, :feature, :string
  end
end
