class CreateFolderDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :folder_documents do |t|
      t.string :content
      t.integer :folder_id
      t.integer :site_id
      t.integer :uploaded_by
      t.string :folder_type
      t.string :of_phase
      t.integer :unit_id
      t.string :heavy_video_url

      t.timestamps
    end
  end
end
