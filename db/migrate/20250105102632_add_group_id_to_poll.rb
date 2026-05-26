class AddGroupIdToPoll < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :group_id, :integer
    add_column :polls, :group_name, :string
    add_column :polls, :share_with, :string
    add_column :polls, :start_time, :time
    add_column :polls, :end_time, :time
  end
end
