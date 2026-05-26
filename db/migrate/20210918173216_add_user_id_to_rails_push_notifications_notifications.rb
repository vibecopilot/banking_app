class AddUserIdToRailsPushNotificationsNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :rails_push_notifications_notifications, :user_id, :integer
  end
end
