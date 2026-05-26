class CreateForumComments < ActiveRecord::Migration[5.1]
  def change
    create_table :forum_comments do |t|
      t.references :forum, foreign_key: true
      t.text :comment
      t.attachment :image

      t.timestamps
    end
  end
end
