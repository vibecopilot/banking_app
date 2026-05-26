class AddLotusBleKeyToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :lotus_ble_key, :string
  end
end
