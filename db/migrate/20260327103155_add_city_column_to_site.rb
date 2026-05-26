class AddCityColumnToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :city, :string
    add_column :sites, :address, :string
  end
end
