class AddReservedToParkingConfiguration < ActiveRecord::Migration[5.1]
  def change
    add_column :parking_configurations, :is_reserved, :boolean
    add_column :parking_configurations, :reserved_for_user_id, :integer
  end
end
