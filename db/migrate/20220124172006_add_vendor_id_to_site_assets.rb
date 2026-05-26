class AddVendorIdToSiteAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :site_assets, :vendor_id, :integer
  end
end
