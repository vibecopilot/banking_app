class AddParkingSlotAndVisitorInOutToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :parking_slot, :integer
    add_column :visitors, :visitor_in_out, :string
  end
end
