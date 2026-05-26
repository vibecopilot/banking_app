class AddFloorColumnToBuilding < ActiveRecord::Migration[5.1]
  def change
    add_column :buildings, :floor_no, :string
  end
end
