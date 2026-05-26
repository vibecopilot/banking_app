class AddComprehensiveToSiteAsset < ActiveRecord::Migration[5.1]
  def change
    add_column :site_assets, :comprehensive, :boolean
  end
end
