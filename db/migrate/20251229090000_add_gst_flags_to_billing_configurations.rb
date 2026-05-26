class AddGstFlagsToBillingConfigurations < ActiveRecord::Migration[5.1]
  def change
    add_column :billing_configurations, :enable_gst_split, :boolean, default: false, null: false
    add_column :billing_configurations, :enable_igst, :boolean, default: false, null: false
  end
end
