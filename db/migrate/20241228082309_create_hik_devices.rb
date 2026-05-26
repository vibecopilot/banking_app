class CreateHikDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :hik_devices do |t|
      t.string :name
      t.string :ip_address
      t.string :username
      t.string :password
      t.integer :site_id
      t.integer :building_id

      t.timestamps
    end
  end
end
