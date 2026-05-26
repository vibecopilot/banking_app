class CreateUserDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :user_devices do |t|
      t.integer :user_id
      t.integer :device_id
      t.string :device_type
      t.string :gcm_key
      t.string :device_name
      t.string :device_os_version
      t.integer :app_id

      t.timestamps
    end
  end
end
