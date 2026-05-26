class AddConsumptionViewToAssetParams < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_params, :consumption_view, :boolean, default: false
  end
end
