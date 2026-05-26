class AddParkingConfToParkingConfiguration < ActiveRecord::Migration[5.1]
  def change
    add_column :parking_configurations, :zone_type, :string unless column_exists?(:parking_configurations, :zone_type)
    add_column :parking_configurations, :no_of_parking_allowed, :string unless column_exists?(:parking_configurations, :no_of_parking_allowed)
    add_column :parking_configurations, :parking_mechanism, :string unless column_exists?(:parking_configurations, :parking_mechanism)
    add_column :parking_configurations, :no_of_levels, :string unless column_exists?(:parking_configurations, :no_of_levels)
    add_column :parking_configurations, :no_of_units, :string unless column_exists?(:parking_configurations, :no_of_units)
    add_column :parking_configurations, :platform_type, :string unless column_exists?(:parking_configurations, :platform_type)
    add_column :parking_configurations, :stack_type, :string unless column_exists?(:parking_configurations, :stack_type)
    add_column :parking_configurations, :access_mode, :string unless column_exists?(:parking_configurations, :access_mode)
    add_column :parking_configurations, :slot_per_stack, :string unless column_exists?(:parking_configurations, :slot_per_stack)
    add_column :parking_configurations, :maintenance_freq, :string unless column_exists?(:parking_configurations, :maintenance_freq)
  end
end
