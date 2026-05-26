class AddReadStatusToNoticeUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :notice_users, :read, :boolean, default: false
    add_column :notice_users, :read_at, :datetime
    add_column :notice_users, :archived, :boolean, default: false
    add_column :notice_users, :archived_at, :datetime
  end
end
