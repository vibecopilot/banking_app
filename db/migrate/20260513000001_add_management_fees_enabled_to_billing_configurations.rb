class AddManagementFeesEnabledToBillingConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :billing_configurations, :management_fees_enabled, :boolean, default: false, null: false
  end
end
