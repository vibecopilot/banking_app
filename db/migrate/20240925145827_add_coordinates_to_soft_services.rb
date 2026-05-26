class AddCoordinatesToSoftServices < ActiveRecord::Migration[5.1]
  def change
    add_column :soft_services, :longitude, :float
    add_column :soft_services, :latitude, :float
  end
end
