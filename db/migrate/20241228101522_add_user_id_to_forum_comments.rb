class AddUserIdToForumComments < ActiveRecord::Migration[5.1]
  def change
    add_column :forum_comments, :user_id, :integer
  end
end
