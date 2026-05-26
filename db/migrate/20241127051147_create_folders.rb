class CreateFolders < ActiveRecord::Migration[5.1]
  def change
    create_table :folders do |t|
      t.string :name
      t.integer :parent_id
      t.string :structure
      t.date :date_of_upload
      t.text :description
      t.integer :site_id
      t.integer :uploaded_by
      t.string :folder_type
      t.integer :unit_id

      t.timestamps
    end
  end
end
