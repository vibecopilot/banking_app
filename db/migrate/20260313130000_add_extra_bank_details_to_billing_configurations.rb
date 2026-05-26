class AddExtraBankDetailsToBillingConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :billing_configurations, :favouring_name, :string
    add_column :billing_configurations, :account_type, :string
    add_column :billing_configurations, :swift_code, :string
  end
end
