class CreateAssetGroupParams < ActiveRecord::Migration[5.1]
  def change
    create_table :asset_group_params do |t|
      t.string :name
      t.integer :order
      t.integer :asset_group_id
      t.boolean :dashboard_view
      t.boolean :consumption_view

      t.timestamps
    end
    add_column :asset_params, :order, :integer
  end
end
