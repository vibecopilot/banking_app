class AddColumnsToAssetAmcs < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_amcs, :first_service, :date
    add_column :asset_amcs, :visits, :integer
    add_column :asset_amcs, :amc_cost, :decimal, precision: 10, scale: 2
    add_column :asset_amcs, :remarks, :text
  end
end
