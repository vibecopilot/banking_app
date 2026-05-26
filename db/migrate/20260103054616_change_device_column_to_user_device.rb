class ChangeDeviceColumnToUserDevice < ActiveRecord::Migration[5.1]
  def change
    change_column_default :user_devices, :full_screen, true
  end
end
