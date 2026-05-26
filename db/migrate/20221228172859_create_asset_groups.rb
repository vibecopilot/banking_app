class CreateAssetGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :asset_groups do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
