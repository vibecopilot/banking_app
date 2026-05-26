class CreateAssetParams < ActiveRecord::Migration[5.1]
  def change
    create_table :asset_params do |t|
      t.integer :asset_id
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
