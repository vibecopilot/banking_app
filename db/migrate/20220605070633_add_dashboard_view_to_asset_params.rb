class AddDashboardViewToAssetParams < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_params, :dashboard_view, :boolean, :default => false
  end
end
