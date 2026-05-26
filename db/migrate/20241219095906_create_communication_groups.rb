class CreateCommunicationGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :communication_groups do |t|
      t.string :name, null: false
      t.text :description
      t.string :picture_file_name
      t.string :picture_content_type
      t.integer :picture_file_size
      t.datetime :picture_updated_at

      t.timestamps
    end
  end
end
