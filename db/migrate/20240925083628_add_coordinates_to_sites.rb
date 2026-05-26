class AddCoordinatesToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :longitude, :float
    add_column :sites, :latitude, :float
  end
end
