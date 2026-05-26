class AddReadStatusToPollUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :poll_users, :read, :boolean, default: false
    add_column :poll_users, :read_at, :datetime
    add_column :poll_users, :archived, :boolean, default: false
    add_column :poll_users, :archived_at, :datetime
  end
end
