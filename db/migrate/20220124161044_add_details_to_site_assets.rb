class AddDetailsToSiteAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :site_assets, :oem_name, :string
    add_column :site_assets, :capacity, :string
    add_column :site_assets, :installation, :date
    add_column :site_assets, :warranty_start, :date
    add_column :site_assets, :remarks, :text
  end
end
