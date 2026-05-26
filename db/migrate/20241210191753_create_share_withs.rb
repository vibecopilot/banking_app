class CreateShareWiths < ActiveRecord::Migration[5.1]
  def change
    create_table :share_withs do |t|
      t.integer :user_id
      t.integer :shared_by
      t.integer :folder_id
      t.integer :document_id

      t.timestamps
    end
  end
end
