class AddAlertBelowToAssetParams < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_params, :alert_below, :float
    add_column :asset_params, :alert_above, :float
    add_column :asset_params, :min_val, :float
    add_column :asset_params, :max_val, :float
    add_column :asset_params, :check_prev, :boolean
    add_column :asset_groups, :company_id, :integer
    add_column :site_assets, :uom, :string
    add_column :site_assets, :asset_type, :string
    add_column :site_assets, :asset_sub_group_id, :integer
    add_column :items, :active, :boolean
    add_column :items, :group_id, :integer
    add_column :items, :sub_group_id, :integer
  end
end
