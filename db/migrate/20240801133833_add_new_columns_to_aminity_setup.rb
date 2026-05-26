class AddNewColumnsToAminitySetup < ActiveRecord::Migration[5.1]
  def change
    add_column :aminity_setups, :facility_type, :string
    add_column :aminity_setups, :facility_name, :string
    add_column :aminity_setups, :active, :boolean
    add_column :aminity_setups, :fee, :float
    add_column :aminity_setups, :booking_allowed_before, :integer
    add_column :aminity_setups, :advance_booking, :integer
    add_column :aminity_setups, :cancel_before, :integer
    add_column :aminity_setups, :description, :text
  end
end
