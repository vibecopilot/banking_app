class CreateFitOutSetupCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :fit_out_setup_categories do |t|
      t.string :name
      t.integer :position
      t.integer :society_id
      t.integer :tat
      t.boolean :active
      t.integer :issue_type_id
      t.string :of_phase
      t.string :of_atype
      t.string :icon_file_name
      t.string :icon_content_type
      t.integer :icon_file_size
      t.datetime :icon_updated_at
      t.text :response_tat
      t.integer :project_tat

      t.timestamps
    end
  end
end
