class AddGroupIdToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :group_id, :integer
  end
end
