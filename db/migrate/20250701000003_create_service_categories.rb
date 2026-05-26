class CreateServiceCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :service_categories do |t|
      t.string :name, null: false
      t.string :description
      t.string :icon_url
      t.integer :sort_order, default: 0
      t.boolean :active, default: true
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end

    # add_index :service_categories, [:site_id, :name], unique: true
    # add_index :service_categories, [:site_id, :sort_order]
  end
end
