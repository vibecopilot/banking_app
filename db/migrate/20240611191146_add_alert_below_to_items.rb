class AddAlertBelowToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :min_stock, :integer
    add_column :items, :max_stock, :integer
    add_column :asset_groups, :group_for, :string, :default => "asset"
    add_column :activities, :soft_service_id, :integer
  end
end
