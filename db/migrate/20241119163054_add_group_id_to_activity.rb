class AddGroupIdToActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :group_id, :integer
  end
end
