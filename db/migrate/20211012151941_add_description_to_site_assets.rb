class AddDescriptionToSiteAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :site_assets, :description, :text
  end
end
