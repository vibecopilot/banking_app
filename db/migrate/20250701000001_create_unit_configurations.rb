class CreateUnitConfigurations < ActiveRecord::Migration[5.1]
  def change
    create_table :unit_configurations do |t|
      t.string :name, null: false # e.g., "1 BHK", "2 BHK", "3 BHK", "Studio"
      t.string :description
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :halls
      t.integer :kitchens
      t.decimal :carpet_area, precision: 8, scale: 2
      t.decimal :built_up_area, precision: 8, scale: 2
      t.boolean :active, default: true
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end

    add_index :unit_configurations, [:site_id, :name], unique: true
  end
end
