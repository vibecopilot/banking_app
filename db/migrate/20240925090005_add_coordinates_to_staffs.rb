class AddCoordinatesToStaffs < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :longitude, :float
    add_column :staffs, :latitude, :float
  end
end
