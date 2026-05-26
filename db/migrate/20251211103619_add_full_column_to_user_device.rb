class AddFullColumnToUserDevice < ActiveRecord::Migration[5.1]
  def change
    add_column :user_devices, :full_screen, :boolean
    add_column :user_devices, :call, :boolean
  end
end
