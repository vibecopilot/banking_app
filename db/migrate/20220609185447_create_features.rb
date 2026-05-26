class CreateFeatures < ActiveRecord::Migration[5.1]
  def change
    create_table :features do |t|
      t.integer :site_id
      t.string :feature_name
      t.integer :created_by

      t.timestamps
    end
  end
end
