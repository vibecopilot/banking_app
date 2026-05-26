class AddDigitToAssetParams < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_params, :digit, :string
  end
end
