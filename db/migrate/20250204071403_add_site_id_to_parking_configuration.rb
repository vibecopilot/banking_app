class AddSiteIdToParkingConfiguration < ActiveRecord::Migration[5.1]
  def change
    add_column :parking_configurations, :site_id, :integer
  end
end
