class AddAttachmentFileToAttachments < ActiveRecord::Migration[5.1]
  def change
      create_table :attachments do |t|
      t.references :incident, foreign_key: true
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at

      t.timestamps
    end
  end
end
