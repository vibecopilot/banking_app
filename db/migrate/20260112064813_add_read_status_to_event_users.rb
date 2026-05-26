class AddReadStatusToEventUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :event_users, :read, :boolean, default: false
    add_column :event_users, :read_at, :datetime
    add_column :event_users, :archived, :boolean, default: false
    add_column :event_users, :archived_at, :datetime
  end
end
