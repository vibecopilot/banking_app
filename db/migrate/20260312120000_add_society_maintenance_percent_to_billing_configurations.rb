class AddSocietyMaintenancePercentToBillingConfigurations < ActiveRecord::Migration[5.1]
  def change
    add_column :billing_configurations, :society_maintenance_percent, :decimal, precision: 5, scale: 2, default: 0.0, null: false
  end
end
