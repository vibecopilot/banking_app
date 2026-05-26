class AddAssetIdToGdnInventoryDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :gdn_inventory_details, :service_id, :integer
    add_column :gdn_inventory_details, :asset_id, :integer
  end
end
