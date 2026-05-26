class CreateHazardCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :hazard_categories do |t|
      t.string :name
      t.text :description
      t.integer :sub_activity_id
      t.integer :activity_id
      t.integer :site_id

      t.timestamps
    end
  end
end
