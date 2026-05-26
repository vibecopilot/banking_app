class AddAssetGroupIdToSiteAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :site_assets, :asset_group_id, :integer
  end
end
