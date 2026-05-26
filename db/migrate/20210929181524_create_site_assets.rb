class CreateSiteAssets < ActiveRecord::Migration[5.1]
  def change
    create_table :site_assets do |t|
      t.integer :site_id
      t.integer :building_id
      t.integer :floor_id
      t.integer :unit_id
      t.string :name
      t.string :serial_number
      t.string :model_number
      t.date :purchased_on
      t.float :purchase_cost
      t.date :warranty_expiry
      t.integer :user_id
      t.boolean :critical
      t.boolean :breakdown
      t.boolean :is_meter
      t.integer :parent_asset_id
      t.boolean :active

      t.timestamps
    end
  end
end
