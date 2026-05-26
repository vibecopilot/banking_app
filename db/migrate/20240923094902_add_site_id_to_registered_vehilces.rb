class AddSiteIdToRegisteredVehilces < ActiveRecord::Migration[5.1]
  def change
    add_column :registered_vehicles, :site_id, :integer
  end
end
