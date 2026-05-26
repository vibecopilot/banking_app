class AddUnitConfigurationToUnits < ActiveRecord::Migration[5.1]
  def change
    add_reference :units, :unit_configuration, null: true, foreign_key: true
  end
end
