class AddFloorIdToCamBill < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bills, :floor_id, :integer
  end
end
