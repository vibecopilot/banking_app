class AddSiteIdToStatusRestaurant < ActiveRecord::Migration[5.1]
  def change
    add_column :status_restaurants, :site_id, :integer
  end
end
