class CreateSavedForums < ActiveRecord::Migration[5.1]
  def change
    create_table :saved_forums do |t|
      t.references :user, null: false, foreign_key: true
      t.references :forum, null: false, foreign_key: true

      t.timestamps
    end

    add_index :saved_forums, [:user_id, :forum_id], unique: true
  end
end
