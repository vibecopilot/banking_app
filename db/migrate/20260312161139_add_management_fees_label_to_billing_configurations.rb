class AddManagementFeesLabelToBillingConfigurations < ActiveRecord::Migration[5.1]
  def change
    add_column :billing_configurations, :management_fees_label, :string, default: 'Management Fees'
  end
end
