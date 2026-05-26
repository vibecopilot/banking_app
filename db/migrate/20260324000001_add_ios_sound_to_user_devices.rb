class AddIosSoundToUserDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :user_devices, :ios_sound, :string
  end
end
