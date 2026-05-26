class CreateAssetMeasures < ActiveRecord::Migration[5.1]
  def change
    create_table :asset_measures do |t|
      t.integer :asset_id
      t.string :name
      t.float :min_value
      t.float :max_value
      t.float :alert_below
      t.float :alert_above
      t.integer :active
      t.string :unit_type
      t.integer :multiplier_factor
      t.string :meter_tag
      t.integer :meter_unit_id
      t.boolean :cloned
      t.boolean :check_previous_reading

      t.timestamps
    end
  end
end
