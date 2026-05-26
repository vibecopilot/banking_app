class AddStatusToLikes < ActiveRecord::Migration[5.1]
  def change
    add_column :likes, :status, :string, default: 'unliked', null: false
  end
end
