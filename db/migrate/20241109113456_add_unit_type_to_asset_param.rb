class AddUnitTypeToAssetParam < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_params, :unit_type, :string
    add_column :asset_params, :multiplier_factor, :integer

  end
end
