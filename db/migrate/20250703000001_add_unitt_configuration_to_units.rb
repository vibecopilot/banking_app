class AddUnittConfigurationToUnits < ActiveRecord::Migration[5.1]
  def change
    unless column_exists?(:units, :unit_configuration_id)
      add_reference :units, :unit_configuration, null: true, foreign_key: true
      add_index :units, :unit_configuration_id
    end
  end
end
