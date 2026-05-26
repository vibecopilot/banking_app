class AddLatitudeLongitudeToSiteAsset < ActiveRecord::Migration[5.1]
  def change
    add_column :site_assets, :latitude, :float
    add_column :site_assets, :longitude, :float
  end
end
